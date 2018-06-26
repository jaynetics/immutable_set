// This speeds up set methods that take an enum by iterating both in parallel.
// Simple sanity checks and casting the arg to set are done in Ruby beforehand.
// Internal hashes of the recipient and arg must have been created in order.

#ifndef HAVE_STRUCT_ST_TABLE_ENTRIES
  // the optional extension doesn't work for ruby < 2.4, skip defining module
  void Init_immutable_set() {}
#else

#include "ruby.h"
#include "ruby/st.h"

enum iter_state  {A_LT_B = -1, A_EQ_B = 0, A_GT_B = 1, EOF_A = -2, EOF_B = -3};
enum iter_action {ITER_ADVANCE_A, ITER_ADVANCE_B, ITER_ADVANCE_BOTH, ITER_END};

typedef enum iter_state(*compare_function)(VALUE, VALUE);
typedef enum iter_action(*comp_callback)(enum iter_state, VALUE*);
typedef enum iter_action(*proc_callback)(enum iter_state, VALUE*, VALUE, VALUE);

static enum iter_state
compare_fixnum_values(VALUE a, VALUE b) {
  if (a < b) return A_LT_B;
  if (a > b) return A_GT_B;
             return A_EQ_B;
}

static enum iter_state
compare_any_values(VALUE a, VALUE b) {
  return rb_cmpint(rb_funcallv(a, rb_intern("<=>"), 1, &b), a, b);
}

#ifndef STRING_P
# define STRING_P(s) (RB_TYPE_P((s), T_STRING) && CLASS_OF(s) == rb_cString)
#endif

static compare_function
optimal_compare_function(VALUE set_a, VALUE set_b) {
  VALUE max_a, max_b;

  max_a = rb_iv_get(set_a, "@max");
  max_b = rb_iv_get(set_b, "@max");

  if (FIXNUM_P(max_a) && FIXNUM_P(max_b)) return compare_fixnum_values;
  if (STRING_P(max_a) && STRING_P(max_b)) return rb_str_cmp;
  return compare_any_values;
}

struct LOC_st_stable_entry {
  st_index_t hash;
  st_data_t key;
  st_data_t record;
};

static struct LOC_st_stable_entry*
set_entries_ptr(VALUE set, st_index_t* size_ptr) {
  VALUE hash;

  hash = rb_iv_get(set, "@hash");
  *size_ptr = RHASH_SIZE(hash);

  return (struct LOC_st_stable_entry*)RHASH_TBL(hash)->entries;
}

#define PARALLEL_ITERATE(...) \
  st_index_t size_a, size_b, i, j; \
  compare_function compare_func; \
  enum iter_state state; \
  struct LOC_st_stable_entry *entries_a, *entries_b; \
  VALUE entry_a, entry_b; \
  \
  entries_a = set_entries_ptr(set_a, &size_a); \
  entries_b = set_entries_ptr(set_b, &size_b); \
  if (!size_a || !size_b) return memo; \
  \
  i = j = 0; \
  entry_a = entries_a[i].key; \
  entry_b = entries_b[j].key; \
  compare_func = optimal_compare_function(set_a, set_b); \
  \
  for (;;) {  \
    state = (*compare_func)(entry_a, entry_b);  \
  \
    eval_state:  \
      switch((*callback)(state, __VA_ARGS__)) {  \
        case ITER_ADVANCE_A:  \
          if (++i >= size_a) { state = EOF_A; goto eval_state; }  \
          entry_a = entries_a[i].key;  \
          continue;  \
        case ITER_ADVANCE_B:  \
          if (++j >= size_b) { state = EOF_B; goto eval_state; }  \
          entry_b = entries_b[j].key;  \
          continue;  \
        case ITER_ADVANCE_BOTH:  \
          if (++i >= size_a) { state = EOF_A; goto eval_state; }  \
          entry_a = entries_a[i].key;  \
          if (++j >= size_b) { state = EOF_B; goto eval_state; }  \
          entry_b = entries_b[j].key;  \
          continue;  \
        case ITER_END:  \
          return memo;  \
      }  \
  }  \

static VALUE
parallel_compare(VALUE set_a, VALUE set_b, comp_callback callback, VALUE memo) {
  PARALLEL_ITERATE(&memo);
}

static VALUE
parallel_process(VALUE set_a, VALUE set_b, proc_callback callback, VALUE memo) {
  PARALLEL_ITERATE(&memo, entry_a, entry_b);
}

static enum iter_action
check_first_subset_of_second(enum iter_state state, VALUE* memo) {
  switch(state) {
    case A_LT_B: *memo = Qfalse; break; // entry_a not in set_b
    case A_EQ_B: return ITER_ADVANCE_BOTH;
    case A_GT_B: return ITER_ADVANCE_B;
    case EOF_A:  *memo = Qtrue; break; // checked all in set_a
    case EOF_B:  *memo = Qfalse; break; // no more comparandi in set_b
  }
  return ITER_END;
}

// Returns Qtrue if SET_A is a subset (proper or not) of SET_B, else Qfalse.
static VALUE
method_subset_p(VALUE self, VALUE set_a, VALUE set_b) {
  return parallel_compare(set_a, set_b, check_first_subset_of_second, Qfalse);
}

// Returns Qtrue if SET_A is a superset (proper or not) of SET_B, else Qfalse.
static VALUE
method_superset_p(VALUE self, VALUE set_a, VALUE set_b) {
  return parallel_compare(set_b, set_a, check_first_subset_of_second, Qfalse);
}

// TODO: if (a > b max || b > a max) *memo = Qfalse; break; ?
static enum iter_action
check_if_intersect(enum iter_state state, VALUE* memo) {
  switch(state) {
    case A_LT_B: return ITER_ADVANCE_A;
    case A_EQ_B: *memo = Qtrue; break; // found common member
    case A_GT_B: return ITER_ADVANCE_B;
    case EOF_A:  *memo = Qfalse; break;
    case EOF_B:  *memo = Qfalse; break;
  }
  return ITER_END;
}

// Returns Qtrue if SET_A intersects with SET_B, else Qfalse.
static VALUE
method_intersect_p(VALUE self, VALUE set_a, VALUE set_b) {
  return parallel_compare(set_a, set_b, check_if_intersect, Qfalse);
}

static void
set_max_ivar_for_set(VALUE set) {
  struct LOC_st_stable_entry *entries;
  st_index_t size;

  entries = set_entries_ptr(set, &size);
  if (size) rb_iv_set(set, "@max", entries[size - 1].key);
}

#define MEMO_HASH           (memo[0])
#define MEMO_SET_A_DEPLETED (memo[1])
#define MEMO_SET_B_DEPLETED (memo[2])

// helper to process two sets and build a new one in parallel
static VALUE
parallel_build(VALUE set_a, VALUE set_b, proc_callback proc) {
  VALUE new_set, new_hash, memo[3];

  // prepare new Set
  new_set = rb_class_new_instance(0, 0, RBASIC(set_a)->klass);
  new_hash = rb_hash_new();
  rb_iv_set(new_set, "@hash", new_hash);

  MEMO_HASH = new_hash;
  MEMO_SET_A_DEPLETED = 0;
  MEMO_SET_B_DEPLETED = 0;

  parallel_process(set_a, set_b, proc, (VALUE)memo);

  set_max_ivar_for_set(new_set);
  rb_obj_freeze(new_hash);

  return new_set;
}

static enum iter_action
add_shared_to_hash(enum iter_state state, VALUE* memp, VALUE a, VALUE b) {
  VALUE *memo;

  switch(state) {
    case A_LT_B: return ITER_ADVANCE_A;
    case A_EQ_B:
      memo = (VALUE*)*memp;
      st_insert(RHASH_TBL(MEMO_HASH), a, Qtrue);
      return ITER_ADVANCE_BOTH;
    case A_GT_B: return ITER_ADVANCE_B;
    case EOF_A:  break;
    case EOF_B:  break;
  }
  return ITER_END;
}

// Returns a new set containing all members shared by SET_A and SET_B.
static VALUE
method_intersection(VALUE self, VALUE set_a, VALUE set_b) {
  return parallel_build(set_a, set_b, add_shared_to_hash);
}

static enum iter_action
add_any_members_to_hash(enum iter_state state, VALUE* memp, VALUE a, VALUE b) {
  VALUE *memo = (VALUE*)*memp;

  switch(state) {
    case A_LT_B:
      if (MEMO_SET_A_DEPLETED) { // iterating through leftovers of set b
        st_insert(RHASH_TBL(MEMO_HASH), b, Qtrue);
        return ITER_ADVANCE_B;
      }
      st_insert(RHASH_TBL(MEMO_HASH), a, Qtrue);
      return ITER_ADVANCE_A;
    case A_EQ_B:
      st_insert(RHASH_TBL(MEMO_HASH), a, Qtrue);
      return ITER_ADVANCE_BOTH; // shared member
    case A_GT_B:
      if (MEMO_SET_B_DEPLETED) { // iterating through leftovers of set a
        st_insert(RHASH_TBL(MEMO_HASH), a, Qtrue);
        return ITER_ADVANCE_A;
      }
      st_insert(RHASH_TBL(MEMO_HASH), b, Qtrue);
      return ITER_ADVANCE_B;
    case EOF_A:
      st_insert(RHASH_TBL(MEMO_HASH), b, Qtrue);
      MEMO_SET_A_DEPLETED = 1;
      if (MEMO_SET_B_DEPLETED) break; // break if both sets depleted
      return ITER_ADVANCE_B;
    case EOF_B:
      st_insert(RHASH_TBL(MEMO_HASH), a, Qtrue);
      MEMO_SET_B_DEPLETED = 1;
      if (MEMO_SET_A_DEPLETED) break; // break if both sets depleted
      return ITER_ADVANCE_A;
  }
  return ITER_END;
}

// Returns a new set that includes all members of SET_A and/or SET_B.
static VALUE
method_union(VALUE self, VALUE set_a, VALUE set_b) {
  return parallel_build(set_a, set_b, add_any_members_to_hash);
}

#define INSERT_UNLESS_EQUAL(val, other, hsh) \
  if (compare_any_values(val, other)) { st_insert(RHASH_TBL(hsh), val, Qtrue); }

static enum iter_action
add_nonb_members_to_hash(enum iter_state state, VALUE* memp, VALUE a, VALUE b) {
  VALUE *memo = (VALUE*)*memp;

  switch(state) {
    case A_LT_B:
      st_insert(RHASH_TBL(MEMO_HASH), a, Qtrue);
      return ITER_ADVANCE_A;
    case A_EQ_B:
      return ITER_ADVANCE_BOTH; // shared member
    case A_GT_B:
      if (MEMO_SET_B_DEPLETED) { // iterating through leftovers of set a
        st_insert(RHASH_TBL(MEMO_HASH), a, Qtrue);
        return ITER_ADVANCE_A;
      }
      return ITER_ADVANCE_B;
    case EOF_A:
      // if set b is also depleted, add a unless equal to final b
      if (MEMO_SET_B_DEPLETED) { INSERT_UNLESS_EQUAL(a, b, MEMO_HASH); }
      break;
    case EOF_B:
      MEMO_SET_B_DEPLETED = 1;
      return ITER_ADVANCE_A;
  }
  return ITER_END;
}

// Returns a new set that includes any member of either passed set.
static VALUE
method_difference(VALUE self, VALUE set_a, VALUE set_b) {
  return parallel_build(set_a, set_b, add_nonb_members_to_hash);
}

static enum iter_action
add_xor_members_to_hash(enum iter_state state, VALUE* memp, VALUE a, VALUE b) {
  VALUE *memo = (VALUE*)*memp;

  switch(state) {
    case A_LT_B:
      if (MEMO_SET_A_DEPLETED) { // iterating through leftovers of set b
        st_insert(RHASH_TBL(MEMO_HASH), b, Qtrue);
        return ITER_ADVANCE_B;
      }
      st_insert(RHASH_TBL(MEMO_HASH), a, Qtrue);
      return ITER_ADVANCE_A;
    case A_EQ_B:
      return ITER_ADVANCE_BOTH; // shared member, skip
    case A_GT_B:
      if (MEMO_SET_B_DEPLETED) { // iterating through leftovers of set a
        st_insert(RHASH_TBL(MEMO_HASH), a, Qtrue);
        return ITER_ADVANCE_A;
      }
      st_insert(RHASH_TBL(MEMO_HASH), b, Qtrue);
      return ITER_ADVANCE_B;
    case EOF_A:
      // if set b is also depleted, add a unless equal to final b and break
      if (MEMO_SET_B_DEPLETED) { INSERT_UNLESS_EQUAL(a, b, MEMO_HASH); break; }
      INSERT_UNLESS_EQUAL(b, a, MEMO_HASH); // add b unless equal to final a
      MEMO_SET_A_DEPLETED = 1; // mark set a as depleted
      return ITER_ADVANCE_B;
    case EOF_B:
      // if set a is also depleted, add b unless equal to final a and break
      if (MEMO_SET_A_DEPLETED) { INSERT_UNLESS_EQUAL(b, a, MEMO_HASH); break; }
      INSERT_UNLESS_EQUAL(a, b, MEMO_HASH); // add a unless equal to final b
      MEMO_SET_B_DEPLETED = 1; // mark set b as depleted
      return ITER_ADVANCE_A;
  }
  return ITER_END;
}

// Returns a new set that is a XOR result of SET_A and SET_B.
static VALUE
method_exclusion(VALUE self, VALUE set_a, VALUE set_b) {
  return parallel_build(set_a, set_b, add_xor_members_to_hash);
}

#define INCR_FIXNUM_ID(id) (id += 2)
#define DECR_FIXNUM_ID(id) (id -= 2)

#define GET_RANGE_FIXNUM_IDS(range, from_id, upto_id) \
  int excl; \
  if (!rb_range_values(range, &from_id, &upto_id, &excl)) { \
    rb_raise(rb_eArgError, "Pass a Range"); \
  } \
  if (excl) DECR_FIXNUM_ID(upto_id); \
  Check_Type(from_id, T_FIXNUM); \
  Check_Type(upto_id, T_FIXNUM);

// Fills HASH will all Fixnums in RANGE.
static VALUE
method_fill_with_fixnums(VALUE self, VALUE hash, VALUE range) {
  VALUE from_id, upto_id;
  st_table *tbl;

  GET_RANGE_FIXNUM_IDS(range, from_id, upto_id);
  tbl = RHASH_TBL(hash);

  while (from_id <= upto_id) {
    st_insert(tbl, from_id, Qtrue);
    INCR_FIXNUM_ID(from_id);
  }

  return upto_id;
}

inline static void
insert_fixnum_id(st_table *tbl, VALUE id, int ucp_only) {
  if (!ucp_only || id <= 0x1B000 || id >= 0x1C000) {
    st_insert(tbl, id, Qtrue);
  }
}

// Returns a new set that is a XOR result of SET and the given RANGE.
static VALUE
method_invert_fixnum_set(VALUE self, VALUE set, VALUE range, VALUE ucp) {
  VALUE fixnum_id, upto_id, new_hash, new_set, entry;
  st_index_t size, i;
  int ucp_only;
  st_table *new_tbl;
  struct LOC_st_stable_entry *entries;

  GET_RANGE_FIXNUM_IDS(range, fixnum_id, upto_id);
  ucp_only = ucp != Qfalse && ucp != Qnil && ucp != Qundef;

  // get set members
  entries = set_entries_ptr(set, &size);

  // prepare new Set
  new_set = rb_class_new_instance(0, 0, RBASIC(set)->klass);
  new_hash = rb_hash_new();
  new_tbl = RHASH_TBL(new_hash);
  rb_iv_set(new_set, "@hash", new_hash);

  if (size) {
    i = 0;
    entry = entries[i].key;

    // here is the optimization: skipping unneeded comparisons with lower values
    for (;;) {
      if (fixnum_id == entry) {
        // fixnum_id is in set, compare next fixnum with next set member
        entry = entries[++i].key;
        INCR_FIXNUM_ID(fixnum_id);
        if (i == size || fixnum_id > upto_id) break;
      }
      else if (fixnum_id < entry) {
        // fixnum_id is not in set, include in inversion
        insert_fixnum_id(new_tbl, fixnum_id, ucp_only);
        INCR_FIXNUM_ID(fixnum_id);
        if (fixnum_id > upto_id) break;
      }
      else /* if (fixnum_id > entry) */ {
        // gap; fixnum_id might be in set, check next set member
        entry = entries[++i].key;
        if (i == size) break;
      }
    }
  }

  // include all fixnums beyond the range of the set
  while (fixnum_id <= upto_id) {
    insert_fixnum_id(new_tbl, fixnum_id, ucp_only);
    INCR_FIXNUM_ID(fixnum_id);
  }

  set_max_ivar_for_set(new_set);
  rb_obj_freeze(new_hash);

  return new_set;
}

void Init_immutable_set() {
  VALUE mod;
  mod = rb_define_module("ImmutableSetExt");
  rb_define_singleton_method(mod, "difference",        method_difference,        2);
  rb_define_singleton_method(mod, "exclusion",         method_exclusion,         2);
  rb_define_singleton_method(mod, "fill_with_fixnums", method_fill_with_fixnums, 2);
  rb_define_singleton_method(mod, "intersect?",        method_intersect_p,       2);
  rb_define_singleton_method(mod, "intersection",      method_intersection,      2);
  rb_define_singleton_method(mod, "invert_fixnum_set", method_invert_fixnum_set, 3);
  rb_define_singleton_method(mod, "subset?",           method_subset_p,          2);
  rb_define_singleton_method(mod, "superset?",         method_superset_p,        2);
  rb_define_singleton_method(mod, "union",             method_union,             2);
}

#endif // end of #ifndef HAVE_STRUCT_ST_TABLE_ENTRIES ... #else ...
