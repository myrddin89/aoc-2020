#! /usr/bin/env bash

if [[ -z "$@" ]]; then
    echo "ERROR: please provide entry point"
    echo "Usage: spago.sh <source> <entry-point>"
    exit 1
fi

export INIT_CWD=$(pwd)
cd AdventOfCode.purs
sources=("-p ../$1")
entry_point="$2"
npx spago run "${sources[@]}" -m "$entry_point"
cd $INIT_CWD
unset INIT_CWD
