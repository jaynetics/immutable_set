[![Gem Version](https://badge.fury.io/rb/immutable_set.svg)](http://badge.fury.io/rb/immutable_set)
[![Build Status](https://travis-ci.org/janosch-x/immutable_set.svg?branch=master)](https://travis-ci.org/janosch-x/immutable_set)

# ImmutableSet

A faster, immutable replacement for Ruby's [`Set`](https://ruby-doc.org/stdlib-2.5.1/libdoc/set/rdoc/Set.html).

On Ruby >= 2.4, all operations are faster, some by several orders of magnitude (see [benchmarks](./BENCHMARK.md)).

#### Useful for ...

- creating and working with large sorted sets
- intersecting, merging, diffing, checking for subsets etc.
- the [advantages of immutability](https://hackernoon.com/f98e7e85b6ac)

#### Not useful for ...

- small sets and other cases where performance is negligible
- sets with mixed members or any members that are not mutually comparable
- doing a lot of adding, removing, and checking of single items

## Usage

```ruby
require 'immutable_set'

class MySet < ImmutableSet; end
```

Mutating methods of `Set` (e.g. `#add`, `#delete`) are removed. They can be substituted like this if needed:

```ruby
set1 = MySet[1, 2, 3]
set1 += MySet[4] # => MySet[1, 2, 3, 4]
set1 -= MySet[3] # => MySet[1, 2, 4]
```

Immutability is required for most of the [performance optimizations](#performance-optimizations).

All other methods behave as in `Set`/`SortedSet`, so see the [official documentation](https://ruby-doc.org/stdlib-2.5.1/libdoc/set/rdoc/Set.html) for details about what they do.

## New methods

**#distinct_bounds?**

Returns true iff the passed set is beyond the `#minmax` boundaries of `self`.

```ruby
MySet[2, 4].distinct_bounds?(MySet[3]) # => false
MySet[2, 4].distinct_bounds?(MySet[5]) # => true
```

**::from_ranges**

Returns a set built from all passed `Ranges`.

```ruby
MySet.from_ranges(2..4, 6..8) # => MySet[2, 3, 4, 6, 7, 8]
```

**#inversion**

Returns a new set of the same class, containing all members `from`..`upto` that are not in `self`. Faster than `Set.new(from..upto) - self`.

```ruby
MySet[3, 5].inversion(from: 1, upto: 4) # => MySet[1, 2, 4]`
MySet['c'].inversion(from: 'a', upto: 'd') # => MySet['a', 'b', 'd']
```

## Performance optimizations

The cost of many methods is reduced from O(m*n) to O(m+n) or better. The underlying ideas are:

- never needing to sort, because the internal `@hash` is built in order and then frozen
- remembering `#max` cheaply whenever possible
- this allows skipping unneeded checks for members outside the own `#minmax` boundaries
- avoiding unneeded lookups during comparisons by iterating over both sets in parallel in C
- parallel iteration can skip over gaps in either set since both hashes are ordered
- when using Ruby, preferring `#while` over slower, scope-building iteration methods

## Benchmarks

Run `rake benchmark` or see [BENCHMARK.md](./BENCHMARK.md).
