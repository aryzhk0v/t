#!/bin/sh -e
# t -- simple notes manager
# Copyright (C) 2013-2021 Sergey Matveev <stargrave@stargrave.org>
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

NOTES_DIR=$HOME/.t/$N

purge()
{
    find $NOTES_DIR -size 0 -delete
}

get_note()
{
    find $NOTES_DIR -maxdepth 1 -type f | sort | sed -n $(($1 + 1))p
}

if [ -z "$1" ]; then
    purge
    cnt=0
    for n in $(find $NOTES_DIR -maxdepth 1 -type f | sort); do
        echo "[$cnt]" "$(sed 's/^\(.\{1,70\}\).*$/\1/;q' $n)" "($(sed -n '$=' $n))"
        cnt=$(($cnt + 1))
    done
    exit 0
fi

case "$1" in
a)
    shift
    note=$NOTES_DIR/$(date "+%Y%m%d-%H%M%S")
    [ $# -gt 0 ] && echo "$@" > $note || $EDITOR $note
    ;;
d)
    rm -f $(get_note $2)
    ;;
m)
    $EDITOR $(get_note $2)
    ;;
*)
    note=$(get_note $1)
    [ -e "$note" ] && cat $note || exit 1
    ;;
esac
purge
