Results of `rake:benchmark` on ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-darwin17]

Note: `stdlib` refers to `SortedSet` without the `rbtree` gem. If the `rbtree` gem is present, `SortedSet` will [use it](https://github.com/ruby/ruby/blob/b1a8c64/lib/set.rb#L709-L724) and become even slower.

```
#- with 5M overlapping items
                 gem:        6.6 i/s
           gem w/o c:        0.8 i/s - 7.85x  slower
              stdlib:        0.7 i/s - 9.51x  slower```
```
#- with 5M distinct items
                 gem:  1429392.7 i/s
           gem w/o c:  1414260.7 i/s - same-ish
              stdlib:        1.0 i/s - 1456728.62x  slower```
```
#^ with 5M overlapping items
                 gem:        0.9 i/s
           gem w/o C:        0.4 i/s - 2.12x  slower
              stdlib:        0.4 i/s - 2.16x  slower
```
```
#^ with 5M distinct items
           gem w/o C:        0.8 i/s
                 gem:        0.6 i/s - 1.25x  slower
              stdlib:        0.5 i/s - 1.65x  slower
```
```
#intersect? with 5M intersecting items
                 gem:      266.8 i/s
           gem w/o C:        8.2 i/s - 32.53x  slower
              stdlib:        2.2 i/s - 121.88x  slower
```
```
#intersect? with 5M sparse items (rare case?)
           gem w/o C:     1442.5 i/s
                 gem:      185.2 i/s - 7.79x  slower
              stdlib:        2.0 i/s - 712.75x  slower
```
```
#intersect? with 5M distinct items
                 gem:  1376038.3 i/s
           gem w/o C:  1375048.5 i/s - same-ish
              stdlib:        2.0 i/s - 675307.67x  slower
```
```
#& with 5M intersecting items
                 gem:        6.4 i/s
           gem w/o C:        2.6 i/s - 2.49x  slower
             Array#&:        1.3 i/s - 4.83x  slower
              stdlib:        0.9 i/s - 6.90x  slower
```
```
#& with 5M sparse items (rare case?)
                 gem:       88.3 i/s
           gem w/o C:       19.6 i/s - 4.50x  slower
              stdlib:        2.0 i/s - 44.46x  slower
             Array#&:        1.8 i/s - 49.61x  slower
```
```
#& with 5M distinct items
           gem w/o C:   578891.9 i/s
                 gem:   571604.2 i/s - same-ish
              stdlib:        2.1 i/s - 281016.75x  slower
             Array#&:        1.8 i/s - 316493.80x  slower
```
```
#inversion with 5M items
                 gem:        1.8 i/s
           gem w/o C:        0.7 i/s - 2.58x  slower
           stdlib #-:        0.3 i/s - 6.67x  slower
```
```
#inversion with 100k items
                 gem:      239.5 i/s
           gem w/o C:       62.8 i/s - 3.81x  slower
           stdlib #-:       29.2 i/s - 8.22x  slower
```
```
#minmax with 10M items
                 gem:  3180102.2 i/s
           gem w/o C:  3170355.3 i/s - same-ish
              stdlib:        5.3 i/s - 595743.46x  slower
```
```
#minmax with 1M items
                 gem:  3247178.7 i/s
           gem w/o C:  3231669.0 i/s - same-ish
              stdlib:       52.8 i/s - 61535.19x  slower
```
```
::new with 5M Range items
                 gem:        0.8 i/s
           gem w/o C:        0.6 i/s - 1.27x  slower
              stdlib:        0.4 i/s - 1.78x  slower
```
```
::new with 100k Range items
                 gem:      126.7 i/s
           gem w/o C:       69.2 i/s - 1.83x  slower
              stdlib:       33.1 i/s - 3.83x  slower
```
```
::new with 10k Range items in 10 non-continuous Ranges
                 gem:     3117.6 i/s
           gem w/o C:     1326.2 i/s - 2.35x  slower
              stdlib:      666.7 i/s - 4.68x  slower
```
```
#(proper_)subset/superset? with 5M subset items
                 gem:       50.8 i/s
           gem w/o C:        1.4 i/s - 37.61x  slower
              stdlib:        1.3 i/s - 37.71x  slower
```
```
#(proper_)subset/superset? with 5M overlapping items
                 gem:       51.0 i/s
           gem w/o C:        1.4 i/s - 36.49x  slower
              stdlib:        1.4 i/s - 36.74x  slower
```
```
#(proper_)subset/superset? with 100k overlapping items
                 gem:     3238.3 i/s
              stdlib:      302.9 i/s - 10.69x  slower
           gem w/o C:      281.8 i/s - 11.49x  slower
```
```
#+ with 5M overlapping items
                 gem:        1.4 i/s
              stdlib:        1.2 i/s - 1.19x  slower
           gem w/o C:        0.9 i/s - 1.49x  slower
```
