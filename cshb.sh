#!/usr/bin/env bash

EXE="executable"
SLIB="shared"
ALIB="static"

FILES=()
TARGET="$EXE"
NAME=""
VERSION=""
OUT="bin"

if [[ ! -v CC ]]; then
  CC="gcc"
fi

if [[ ! -v AR ]]; then
  AR="ar"
fi

log() {
    local red='\033[0;31m'
    local green='\033[0;32m'
    local yellow='\033[1;33m'
    local blue='\033[0;34m'
    local nc='\033[0m'

    local currentTime
    currentTime=$(date "+%Y-%m-%d %H:%M:%S")

    local type="$1"
    shift
    local msg="$*"

    case "$type" in
        "INFO") printf "%s - %b[INFO]%b %s\n" "$currentTime" "$blue" "$nc" "$msg" ;;
        "SUCCESS") printf "%s - %b[SUCCESS]%b %s\n" "$currentTime" "$green" "$nc" "$msg" ;;
        "WARNING") printf "%s - %b[WARNING]%b %s\n" "$currentTime" "$yellow" "$nc" "$msg" ;;
        "ERROR") printf "%s - %b[ERROR]%b %s\n" "$currentTime" "$red" "$nc" "$msg" ;;
        *) printf "%s - [LOG] %s\n" "$currentTime" "$msg" ;;
    esac


}

lerr() {
  log ERROR $@
  exit 1
}

# Run executed task
_run() {
  $@ || {
    log ERROR "Failed to execute: '$@'"
  }
}

# Log executed task
_lrun() {
  log INFO "Executing: $@"
  _run $@
}

_fexists() {
  if [ ! -f "$1" ]; then
    lerr "File: $1, doesn't exist."
  fi
}

_to_obj() {
  local out="$OUT/${1//.c/.o}"
  _run mkdir -p "$(dirname "$out")"
  echo "$out"
}


# Build shared library
_sbuild() {
  log INFO "Starting building shared library"

  _lrun mkdir -p "$OUT"
  local count=0

  for file in "${FILES[@]}"; do
    _fexists $file
    local out=$(_to_obj $file)

    _lrun $CC $CFLAGS -c -fPIC $file -o $out
    log SUCCESS "Success build of: $out"

    count=$((count + 1))
  done

  if (( count == 0 )); then
    lerr "There is no input files"
  fi

  local _obj=("${FILES[@]/%.c/.o}")
  local obj=("${_obj[@]/#/"$OUT/"}")
  _lrun $CC -shared -o "$OUT/$NAME.so" ${obj[@]}
  log SUCCESS "Success buid of: $OUT/$NAME.so"
}



# Build static library
_abuild() {
  log INFO "Starting building static library"

  _lrun mkdir -p "$OUT"
  local count=0

  for file in "${FILES[@]}"; do
    _fexists $file
    local out="$OUT/${file//.c/.o}"

    _lrun mkdir -p "$(dirname "$out")"
    _lrun $CC $CFLAGS -c $file -o $out
    count=$((count + 1))

    log SUCCESS "Success build of: $out"
  done

  if (( count == 0 )); then
    lerr "There is no input files"
  fi

  local _obj=("${FILES[@]/%.c/.o}")
  local obj=("${_obj[@]/#/"$OUT/"}")
  _lrun $AR rcs "$OUT/$NAME.a" ${obj[@]}

  log SUCCESS "Success build of: $OUT/$NAME.a"
}



# Build executable
_ebuild() {
  log INFO "Starting building executable"

  _lrun mkdir -p "$OUT"
  local count=0

  for file in "${FILES[@]}"; do
    _fexists $file
    local out="$OUT/${file//.c/.o}"

    _lrun mkdir -p "$(dirname "$out")"
    _lrun $CC $CFLAGS -c $file -o $out
    log SUCCESS "Success build of: $out"
    count=$((count + 1))
  done

  if (( count == 0 )); then
    lerr "There is no input files"
  fi

  local _obj=("${FILES[@]/%.c/.o}")
  local obj=("${_obj[@]/#/"$OUT/"}")
  _lrun $CC -o "$OUT/$NAME" ${obj[@]}
  log SUCCESS "Success build of: $OUT/$NAME"
}


# Build target
build() {
  log INFO "Target: $NAME"
  log INFO "Version: $VERSION"

  case "$TARGET" in
    "$EXE") _ebuild ;;
    "$ALIB") _abuild ;;
    "$SLIB") _sbuild ;;
    *) log WARNING "Didn't specyfiy type of target"; exit 1;;
  esac
}


template_flags() {
  case "$1" in
    "release") echo "-O2 -g0" ;;
    "debug") echo "-O0 -g" ;;
    "native") echo "-O3 -mnative" ;;
    *) echo "";;
  esac
}
