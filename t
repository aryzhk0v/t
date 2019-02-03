#!/bin/sh -e
# t -- simple notes manager
# Copyright (C) 2013-2019 Sergey Matveev <stargrave@stargrave.org>
# Invoke the script without any arguments to briefly print all notes.
# Otherwise you can specify the following ones:
# a   -- add new note (either starts an editor if not arguments are specified,
#        or save them inside the note silently)
# d N -- delete note N
# m N -- modify note N by starting an editor
# N   -- print out note's N contents

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
    note=$NOTES_DIR/$(date '+%s')
    [ $# -gt 0 ] && echo "$@" > $note || $EDITOR $note
    ;;
d)
    rm -f $(get_note $2)
    ;;
m)
    $EDITOR $(get_note $2)
    ;;
*)
    cat $(get_note $1)
    ;;
esac
purge
