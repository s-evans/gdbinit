
# includes
source ~/.gdb/stl-views.gdb
# source ~/.gdb/.gdbinit.other

# enable local gdbinit
set auto-load local-gdbinit on
set auto-load safe-path /

# make things look nice
set print pretty on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set print asm-demangle on
set print array on
set print array-indexes on
set demangle-style gnu-v3

# settings
set history filename .gdb_history
set history save on
set history expansion on
set history size 10000
set verbose off
set confirm off
set disassembly-flavor intel

# aliases
alias -- it = info threads
alias -- ib = info breakpoints
alias -- ia = info args
alias -- ir = info registers
alias -- il = info locals
alias -- all = thread apply all

# commands
define xxd
dump binary memory dump.bin $arg0 $arg0+$arg1
shell xxd dump.bin
end

define hexdump
dump binary memory dump.bin $arg0 $arg0+$arg1
shell hexdump -C dump.bin
end

# python pretty printers
python 

import sys
import os

sys.path.insert( 0, os.path.expanduser( '~/.gdb/bundle/stl' ) )
sys.path.insert( 0, os.path.expanduser( '~/.gdb/bundle/stl/libstdcxx/v6' ) )
from libstdcxx.v6.printers import register_libstdcxx_printers
#register_libstdcxx_printers ( None )

sys.path.insert( 0, os.path.expanduser( '~/.gdb/bundle/boost' ) )
from boost.printers import register_printer_gen
register_printer_gen ( None )

sys.path.insert( 0, os.path.expanduser( '~/.gdb/bundle/qt5' ) )
from qt5printers import register_printers
register_printers (None)

end

