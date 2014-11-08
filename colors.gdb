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
#    call cleanup-color-pipe.
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

shell mkfifo ./.gdb-color-pipe

define setup-color-pipe
    set logging redirect on
    set logging on ./.gdb-color-pipe
end

define cleanup-color-pipe
    set logging off
    set logging redirect off
    shell sleep 0.1s
end

document cleanup-color-pipe
    Disables command redirection and removes the color pipe file.
    Syntax: cleanup-color-pipe
end

define do-generic-colors
    # 1. Function names and the class they belong to
    # 2. Function argument names
    # 3. Stack frame number
    # 4. Thread id colorization
    # 5. File path and line number
    echo \n
    shell cat ./.gdb-color-pipe | \
        sed -r "s_([^<])(\b([a-zA-Z0-9_]+::)?[a-zA-Z0-9_\.@]+)( ?)\(_\1$(tput setaf 6)$(tput bold)\2$(tput sgr0)\4(_g" | \
        sed -r "s_([a-zA-Z0-9_#]*)=_$(tput setaf 2)$(tput bold)\1$(tput sgr0)=_g" | \
        sed -r "s_^(#[0-9]*)_$(tput setaf 1)$(tput bold)\1$(tput sgr0)_" | \
        sed -r "s_^([ \*]) ([0-9]+)_$(tput bold)$(tput setaf 6)\1 $(tput setaf 1)\2$(tput sgr0)_" | \
        sed -r "s_(\.*[/A-Za-z0-9\+_\.\-]*):([0-9]+)\$_$(tput setaf 4)\1$(tput sgr0):$(tput setaf 3)\2$(tput sgr0)_" & 
end

define re
    cleanup-color-pipe
    echo \033[0m
end 

document re
    Restore colorscheme
end 

define hook-quit
    shell rm ./.gdb-color-pipe
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
    do-generic-colors
    setup-color-pipe
end

define hookpost-backtrace
    cleanup-color-pipe
end


#------------------------------------------------------------------------------#
# up
#------------------------------------------------------------------------------#

define hook-up
    do-generic-colors
    setup-color-pipe
end

define hookpost-up
    cleanup-color-pipe
end


#------------------------------------------------------------------------------#
# down
#------------------------------------------------------------------------------#

define hook-down
    do-generic-colors
    setup-color-pipe
end

define hookpost-down
    cleanup-color-pipe
end


#------------------------------------------------------------------------------#
# frame
#------------------------------------------------------------------------------#

define hook-frame
    do-generic-colors
    setup-color-pipe
end

define hookpost-frame
    cleanup-color-pipe
end


#------------------------------------------------------------------------------#
# info threads
#------------------------------------------------------------------------------#

define info hook-threads
    do-generic-colors
    setup-color-pipe
end

define info hookpost-threads
    cleanup-color-pipe
end


#------------------------------------------------------------------------------#
# thread
#------------------------------------------------------------------------------#

define hook-thread
    do-generic-colors
    setup-color-pipe
end

define hookpost-thread
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# disassembly
#------------------------------------------------------------------------------#

define hook-disassemble
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define hookpost-disassemble
    cleanup-color-pipe
end


#------------------------------------------------------------------------------#
# source listing
#------------------------------------------------------------------------------#

define hook-list
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end 

define hookpost-list
    cleanup-color-pipe
end 

#------------------------------------------------------------------------------#
# all registers
#------------------------------------------------------------------------------#

define info hook-all-registers
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-all-registers
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# registers
#------------------------------------------------------------------------------#

define info hook-registers
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-registers
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# breakpoints
#------------------------------------------------------------------------------#

define info hook-breakpoints
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-breakpoints
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# program
#------------------------------------------------------------------------------#

define info hook-program
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-program
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# proc
#------------------------------------------------------------------------------#

define info hook-proc
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-proc
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# args
#------------------------------------------------------------------------------#

define info hook-args
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-args
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# address
#------------------------------------------------------------------------------#

define info hook-address
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-address
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# files
#------------------------------------------------------------------------------#

define info hook-files
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-files
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# float
#------------------------------------------------------------------------------#

define info hook-float
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-float
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# functions
#------------------------------------------------------------------------------#

define info hook-functions
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-functions
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# signals
#------------------------------------------------------------------------------#

define info hook-signals
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-signals
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# inferiors
#------------------------------------------------------------------------------#

define info hook-inferiors
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-inferiors
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# line
#------------------------------------------------------------------------------#

define info hook-line
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-line
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# macro
#------------------------------------------------------------------------------#

define info hook-macro
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-macro
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# macros
#------------------------------------------------------------------------------#

define info hook-macros
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-macros
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# os
#------------------------------------------------------------------------------#

define info hook-os
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=asm -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-os
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# break
#------------------------------------------------------------------------------#

define hook-break
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define hookpost-break
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# skip
#------------------------------------------------------------------------------#

define info hook-skip
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-skip
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# sharedlibrary
#------------------------------------------------------------------------------#

define info hook-sharedlibrary
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-sharedlibrary
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# stack
#------------------------------------------------------------------------------#

define info hook-stack
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-stack
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# symbol
#------------------------------------------------------------------------------#

define info hook-symbol
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-symbol
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# target
#------------------------------------------------------------------------------#

define info hook-target
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-target
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# terminal
#------------------------------------------------------------------------------#

define info hook-terminal
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-terminal
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# step
#------------------------------------------------------------------------------#

define hook-step
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define hookpost-step
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# next
#------------------------------------------------------------------------------#

define hook-next
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define hookpost-next
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# finish
#------------------------------------------------------------------------------#

define hook-finish
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define hookpost-finish
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# watchpoints
#------------------------------------------------------------------------------#

define info hook-watchpoints
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-watchpoints
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# variables
#------------------------------------------------------------------------------#

define info hook-variables
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-variables
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# types
#------------------------------------------------------------------------------#

define info hook-types
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-types
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# tracepoints
#------------------------------------------------------------------------------#

define info hook-tracepoints
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-tracepoints
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# tvariables
#------------------------------------------------------------------------------#

define info hook-tvariables
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=cpp -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define info hookpost-tvariables
    cleanup-color-pipe
end

#------------------------------------------------------------------------------#
# environment
#------------------------------------------------------------------------------#

define show hook-environment
    echo \n
    shell cat ./.gdb-color-pipe | (type highlight >/dev/null 2>&1 && highlight --syntax=sh -s darkness -Oxterm256 || cat) &
    setup-color-pipe
end

define show hookpost-environment
    cleanup-color-pipe
end

