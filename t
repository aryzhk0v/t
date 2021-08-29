#!/usr/bin/env zsh
# t -- simple notes manager
# Copyright (C) 2013-2021 Sergey Matveev <stargrave@stargrave.org>
# Current version is written on zsh. Previous was on POSIX shell.
#
# Usage:
# * t -- just briefly print all notes: their number and stripped first
#   line of content
# * t N -- print N note's contents
# * t a [X X X] -- add a new note to the end. If arguments are specified
#   then they will be the content. Otherwise $EDITOR is started
# * t d N -- delete note number N. Pay attention that other notes may
#   change their numbers!
# * t m N -- edit note N with $EDITOR
# Also you can specify $N environment variable that acts like some kind
# of namespace for the notes (prepare directory first!). For example:
#     $ N=work t a get job done
#     $ N=work t a # it starts $EDITOR
#     $ N=work t
#     [0] get job done (1)
#     [1] this is first line of 3-lines comment (3)
#     $ N=work t d 0
#     $ N=work t
#     [0] this is first line of 3-lines comment (3)
#     $ t
#     [0] some earlier default namespace note (1)

set -e
setopt NULL_GLOB
NOTES_DIR=$HOME/.t/$N
NOTES_DIR=${NOTES_DIR%/}

purge() {
    local empties=($NOTES_DIR/*(.L0))
    [[ $empties ]] && rm $empties || :
}

get_note() {
    [[ "$1" = [0-9]* ]] || { print invalid note id ; exit 1 }
    NOTE=($NOTES_DIR/*(.on[$(( $1 + 1 ))]))
    [[ ${#NOTE} -eq 0 ]] && { print note not found >&2 ; exit 1 }
    NOTE=${NOTE[1]}
}

[[ $# -gt 0 ]] || {
    purge
    local ctr=0
    for note ($NOTES_DIR/*(.on)) {
        read line < $note
        print -n "[$ctr] ${line[1,70]} "
        [[ ${#line} -le 70 ]] || print -n "... "
        lines=$(wc -l < $note)
        printf "(%d)\n" $lines
        ctr=$(( ctr + 1 ))
    }
    exit
}

case $1 in
(a)
    note=$NOTES_DIR/$(date "+%Y%m%d-%H%M%S")
    [[ $# -gt 1 ]] && print -- ${@[2,-1]} > $note || $EDITOR $note
    ;;
(d) get_note $2 ; rm -f $NOTE ;;
(m) get_note $2 ; $EDITOR $NOTE ;;
(*) get_note $1 ; cat $NOTE ;;
esac

purge
