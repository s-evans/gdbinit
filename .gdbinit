
# includes
source ~/.gdb/stl-views.gdb
source ~/.gdb/colors.gdb
source ~/.gdb/.gdbinit.other

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
set demangle-style gnu-v3

# settings
set history filename .gdb_history
set history save on
set history expansion on
set history size 10000
set height 0
set width 0
set verbose off
set confirm off
set disassembly-flavor intel

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
end

