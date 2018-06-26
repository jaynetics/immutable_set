require 'mkmf'

$CFLAGS << ' -Wextra -Wno-unused-parameter -Wall -pedantic '

have_struct_member('struct st_table', 'entries')

create_makefile('immutable_set/immutable_set')
