#! /usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "ERROR: please provide entry point"
    exit 1
else
    entry_point="$1"
fi

export INIT_CWD=$(pwd)
cd AdventOfCode.purs
npx spago run -p "$entry_point"
cd $INIT_CWD
unset INIT_CWD
