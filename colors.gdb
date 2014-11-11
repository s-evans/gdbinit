################################################################################
# colors.gdb
# Rémi Attab (remi.attab@gmail.com), 5 Apr 2013
# FreeBSD-style copyright and disclaimer apply
#
# gdb script that colorizes the output of several gdb functions.
#
# It accomplishes this feat by adding a hook the select gdb functions and
# redirecting the output of the function into a temp file int the current
# folder. In the post hook for the same function, this file is read back and
# piped through ungodly sed commands which colorizes the output.
#
# It also colorizes the prompt as an extra bonus.
#
# Currently supported gdb functions include:
# - backtrace
# - up
# - down
# - frame
# - info threads
# - thread
#
# WARNING: This script introduces a number of annoying behaviours into gdb.
#
#    First up, hooked commands that fail (eg. calling backtrace when no program
#    running or calling down on frame 0) will screw up the output
#    of any following commands. This happens because the post hook is never
#    executed (no idea why) and so the logging remains enabled. To fix this,
#    call cleanup_color_pipe.
#
#    Next, this script uses the logging functionality in gdb so if you're using
#    it to record gdb outputs, this script will break your output whenever you
#    call one of the hook-ed commands.
#
#    Finally, sometimes, when searching through command history (up arrow) the
#    prompt will become borked by including the previous commands. Yet again, I
#    have no idea why this happens.
#
################################################################################

#------------------------------------------------------------------------------#
# Utils
#------------------------------------------------------------------------------#

shell mkfifo ./.gdb_color_pipe

define setup_color_pipe
    set logging redirect on
    set logging on ./.gdb_color_pipe
end

define cleanup_color_pipe
    set logging off
    set logging redirect off
    shell sleep 0.1s
end

document cleanup_color_pipe
    Disables command redirection and removes the color pipe file.
    Syntax: cleanup_color_pipe
end

define do_generic_colors
    # 1. Function names and the class they belong to
    # 2. Function argument names
    # 3. Stack frame number
    # 4. Thread id colorization
    # 5. File path and line number
    echo \n
    shell cat ./.gdb_color_pipe | \
        sed -r "s_([^<])(\b([a-zA-Z0-9_]+::)?[a-zA-Z0-9_\.@]+)( ?)\(_\1$(tput setaf 6)$(tput bold)\2$(tput sgr0)\4(_g" | \
        sed -r "s_([a-zA-Z0-9_#]*)=_$(tput setaf 2)$(tput bold)\1$(tput sgr0)=_g" | \
        sed -r "s_^(#[0-9]*)_$(tput setaf 1)$(tput bold)\1$(tput sgr0)_" | \
        sed -r "s_^([ \*]) ([0-9]+)_$(tput bold)$(tput setaf 6)\1 $(tput setaf 1)\2$(tput sgr0)_" | \
        sed -r "s_(\.*[/A-Za-z0-9\+_\.\-]*):([0-9]+)\$_$(tput setaf 4)\1$(tput sgr0):$(tput setaf 3)\2$(tput sgr0)_" & 
end

define do_cpp_colors
    echo \n
    shell cat ./.gdb_color_pipe | ( ( type source-highlight >/dev/null 2>&1 && source-highlight --src-lang=cpp --out-format=esc ) || ( type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 ) || ( cat ) ) &
end

define do_asm_colors
    echo \n
    shell cat ./.gdb_color_pipe | ( ( type source-highlight >/dev/null 2>&1 && source-highlight --src-lang=asm --out-format=esc ) || ( type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 ) || ( cat ) ) &
end

define do_sh_colors
    echo \n
    shell cat ./.gdb_color_pipe | ( ( type source-highlight >/dev/null 2>&1 && source-highlight --src-lang=asm --out-format=esc ) || ( type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 ) || ( cat ) ) &
end

define re
    cleanup_color_pipe
    echo \033[0m
end 

document re
    Restore colorscheme
end 

define hook-quit
    shell rm ./.gdb_color_pipe
end

#------------------------------------------------------------------------------#
# Prompt
#------------------------------------------------------------------------------#

# \todo I believe this has a tendency to bork the prompt
#set prompt \033[01;34m(gdb) \033[01;00m

#------------------------------------------------------------------------------#
# backtrace
#------------------------------------------------------------------------------#

define hook-backtrace
    do_generic_colors
    setup_color_pipe
end

define hookpost-backtrace
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# up
#------------------------------------------------------------------------------#

define hook-up
    do_generic_colors
    setup_color_pipe
end

define hookpost-up
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# down
#------------------------------------------------------------------------------#

define hook-down
    do_generic_colors
    setup_color_pipe
end

define hookpost-down
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# frame
#------------------------------------------------------------------------------#

define hook-frame
    do_generic_colors
    setup_color_pipe
end

define hookpost-frame
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# info threads
#------------------------------------------------------------------------------#

define info hook-threads
    do_generic_colors
    setup_color_pipe
end

define info hookpost-threads
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# thread
#------------------------------------------------------------------------------#

define hook-thread
    do_generic_colors
    setup_color_pipe
end

define hookpost-thread
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# disassembly
#------------------------------------------------------------------------------#

define hook-disassemble
    do_asm_colors
    setup_color_pipe
end

define hookpost-disassemble
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# source listing
#------------------------------------------------------------------------------#

define hook-list
    do_cpp_colors
    setup_color_pipe
end 

define hookpost-list
    cleanup_color_pipe
end 

#------------------------------------------------------------------------------#
# all registers
#------------------------------------------------------------------------------#

define info hook-all-registers
    do_asm_colors
    setup_color_pipe
end

define info hookpost-all-registers
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# registers
#------------------------------------------------------------------------------#

define info hook-registers
    do_asm_colors
    setup_color_pipe
end

define info hookpost-registers
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# breakpoints
#------------------------------------------------------------------------------#

define info hook-breakpoints
    do_asm_colors
    setup_color_pipe
end

define info hookpost-breakpoints
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# program
#------------------------------------------------------------------------------#

define info hook-program
    do_asm_colors
    setup_color_pipe
end

define info hookpost-program
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# proc
#------------------------------------------------------------------------------#

define info hook-proc
    do_asm_colors
    setup_color_pipe
end

define info hookpost-proc
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# args
#------------------------------------------------------------------------------#

define info hook-args
    do_asm_colors
    setup_color_pipe
end

define info hookpost-args
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# address
#------------------------------------------------------------------------------#

define info hook-address
    do_asm_colors
    setup_color_pipe
end

define info hookpost-address
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# files
#------------------------------------------------------------------------------#

define info hook-files
    do_asm_colors
    setup_color_pipe
end

define info hookpost-files
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# float
#------------------------------------------------------------------------------#

define info hook-float
    do_asm_colors
    setup_color_pipe
end

define info hookpost-float
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# functions
#------------------------------------------------------------------------------#

define info hook-functions
    do_asm_colors
    setup_color_pipe
end

define info hookpost-functions
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# signals
#------------------------------------------------------------------------------#

define info hook-signals
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-signals
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# inferiors
#------------------------------------------------------------------------------#

define info hook-inferiors
    do_asm_colors
    setup_color_pipe
end

define info hookpost-inferiors
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# line
#------------------------------------------------------------------------------#

define info hook-line
    do_asm_colors
    setup_color_pipe
end

define info hookpost-line
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# macro
#------------------------------------------------------------------------------#

define info hook-macro
    do_asm_colors
    setup_color_pipe
end

define info hookpost-macro
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# macros
#------------------------------------------------------------------------------#

define info hook-macros
    do_asm_colors
    setup_color_pipe
end

define info hookpost-macros
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# os
#------------------------------------------------------------------------------#

define info hook-os
    do_asm_colors
    setup_color_pipe
end

define info hookpost-os
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# break
#------------------------------------------------------------------------------#

define hook-break
    do_cpp_colors
    setup_color_pipe
end

define hookpost-break
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# skip
#------------------------------------------------------------------------------#

define info hook-skip
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-skip
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# sharedlibrary
#------------------------------------------------------------------------------#

define info hook-sharedlibrary
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-sharedlibrary
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# stack
#------------------------------------------------------------------------------#

define info hook-stack
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-stack
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# symbol
#------------------------------------------------------------------------------#

define info hook-symbol
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-symbol
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# target
#------------------------------------------------------------------------------#

define info hook-target
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-target
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# terminal
#------------------------------------------------------------------------------#

define info hook-terminal
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-terminal
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# step
#------------------------------------------------------------------------------#

define hook-step
    do_cpp_colors
    setup_color_pipe
end

define hookpost-step
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# next
#------------------------------------------------------------------------------#

define hook-next
    do_cpp_colors
    setup_color_pipe
end

define hookpost-next
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# finish
#------------------------------------------------------------------------------#

define hook-finish
    do_cpp_colors
    setup_color_pipe
end

define hookpost-finish
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# watchpoints
#------------------------------------------------------------------------------#

define info hook-watchpoints
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-watchpoints
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# variables
#------------------------------------------------------------------------------#

define info hook-variables
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-variables
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# types
#------------------------------------------------------------------------------#

define info hook-types
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-types
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# tracepoints
#------------------------------------------------------------------------------#

define info hook-tracepoints
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-tracepoints
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# tvariables
#------------------------------------------------------------------------------#

define info hook-tvariables
    do_cpp_colors
    setup_color_pipe
end

define info hookpost-tvariables
    cleanup_color_pipe
end

#------------------------------------------------------------------------------#
# environment
#------------------------------------------------------------------------------#

define show hook-environment
    do_sh_colors
    setup_color_pipe
end

define show hookpost-environment
    cleanup_color_pipe
end

# vim: set ft=gdb:

