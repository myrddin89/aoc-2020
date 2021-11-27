#! /usr/bin/env bash

if [[ -z "$@" ]]; then
    echo "ERROR: please provide entry point"
    echo "Usage: cargo.sh <entry-point>"
    exit 1
fi

export INIT_CWD=$(pwd)
cd AdventOfCode.rs
entry_point="$1"
cargo run --bin "$entry_point"
cd $INIT_CWD
unset INIT_CWD
