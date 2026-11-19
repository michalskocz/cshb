# cshb

A minimalist, zero-dependency C build system written in pure Bash.

## Features
* Builds **executables** (`$EXE`), **shared libraries** (`.so`, `$SLIB`), and **static libraries** (`.a`, `$ALIB`).
* Built-in compiler flag presets (`release`, `debug`, `native`).

## Quick Start

Source `cshb.sh` in your build script (e.g., `build.sh`):

```bash
#!/usr/bin/env bash
source ./cshb.sh

# Optional clean target
if [ "$1" == "clean" ]; then
  rm -rf "$OUT"
  exit 0
fi

# Or make it yourself
CFLAGS=$(template_flags "$1") # release | debug | native

# Adding additional flags (eg linakge, includes, ...)
CFLAGS="$CFLAGS -lGL"

# Build executable
NAME="app"
TARGET="$EXE"
VERSION="1.0.0"
FILES=("src/main.c" "src/utils.c")
build
```

## Variables

| Variable | Description | Default |
| --- | --- | --- |
| `CC` | C compiler (`gcc`, `clang`, etc.) | `gcc` |
| `AR` | Archiver for static libraries | `ar` |
| `OUT` | Output directory | `bin` |
| `TARGET` | Build type: `$EXE`, `$SLIB`, or `$ALIB` | `$EXE` |
| `NAME` | Output binary/library name | *(required)* |
| `VERSION` | Project version (logged during build) | `""` |
| `FILES` | Bash array of `.c` source files | `()` |
| `CFLAGS` | Compiler flags | `""` |

## License

Dedicated to the public domain under **CC0 1.0 Universal**. See [LICENSE](https://www.google.com/search?q=LICENSE) for details.
