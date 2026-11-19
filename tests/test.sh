#!/usr/bin/env bash

source ../cshb.sh

if [ "$1" == "clean" ]; then
  rm -fr $OUT
  exit 0
fi

CFLAGS=$(template_flags $1)

# EXE

NAME="test"
TARGET="$EXE"

VERSION="1.0.0"
FILES=(
  "src/main.c"
  "src/mul.c"
  "src/add.c"
)

build

# Shared

NAME="test"
TARGET="$SLIB"

VERSION="1.0.0"
FILES=(
  "src/mul.c"
  "src/add.c"
)

build

NAME="test"
TARGET="$ALIB"

VERSION="1.0.0"
FILES=(
  "src/mul.c"
  "src/add.c"
)

build
