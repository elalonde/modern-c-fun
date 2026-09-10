# Tier 0 — Build and verification harness

## Goal

Build the harness that every later exercise uses. The harness has two parts: a shared fragment and, per binary, a small Makefile that includes it.

## Requirements

### The shared fragment

- Holds everything that is the same for every exercise: the language-standard setting, the warning set, the three build targets, the build directory layout, and dependency tracking.
- Is never edited for an exercise. If an exercise needs something the fragment does not provide, the fragment is wrong and you fix it once, for all exercises.
- Supplies a default for the language-standard setting. The including Makefile may replace it.
- Permits the including Makefile to give one source file different compile flags from the rest. 1.5 needs this.
- Is under 60 lines.

### The including Makefile

- Names one binary and its source files, sets the language-standard setting when the tier requires a change, and includes the fragment. It does nothing else.
- One per binary. Some exercises have more than one binary. Tier 0 has four probes. 1.7 has `ub` and `ub_fixed`, both linked with the same `main.c`.

### Language-standard setting

- One variable. Its value is the compiler's standard option and nothing else. Warnings and optimization live elsewhere.
- Tiers 0-2: `-std=c99 -pedantic`. Tier 3 onward: `-std=gnu11`. This changes once per tier, so the including Makefiles in a tier all set the same value, or the fragment default already matches.

### Targets

| Target | Flags | Purpose |
|---|---|---|
| `debug` (default) | `-O0 -g3 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-sanitize-recover=all` | Daily build. Every sanitizer report is a test failure. |
| `hardened` | `-O2 -g -D_FORTIFY_SOURCE=3 -fstack-protector-strong -fstack-clash-protection -fcf-protection=full -Wl,-z,relro,-z,now -Wl,-z,noexecstack` | Release build with the hardening set that distributions use. |
| `analyze` | `-O2 -fanalyzer`, then `clang-tidy` on the sources | Static analysis. Output only. No binary is required. |
| `clean` | | Removes all build output. |

Every target uses the language-standard setting and the warning set below.

Warning set, all targets:

```
-Wall -Wextra -Wshadow -Wconversion -Wsign-conversion -Wstrict-prototypes
-Wmissing-prototypes -Wvla -Wcast-align -Wformat=2 -Wnull-dereference -Wundef
```

`-Werror` is off by default. `WERROR=1` on the command line turns it on.

### Build output

- Goes under `build/<target>/`. The three targets coexist; building one does not disturb another.
- `make -j` works.
- Dependency tracking with `-MMD -MP`. Editing a header rebuilds what includes it.
- `compile_commands.json` exists so `clang-tidy` can run. `bear -- make debug` is acceptable.

### Tools

- GNU Make only. No autotools, no CMake.

## Verification

Four probe programs are provided. Each one triggers exactly one detector. Build each with the harness and confirm the result.

| Probe | Target | Required result |
|---|---|---|
| `probe_asan.c` | `debug` | AddressSanitizer reports `heap-buffer-overflow`. Exit status is non-zero. |
| `probe_ubsan.c` | `debug`, argument `2147483647` | UBSan reports `signed integer overflow`. Exit status is non-zero. |
| `probe_fortify.c` | `hardened`, a 40-character argument | glibc reports `buffer overflow detected` and aborts. |
| `probe_analyzer.c` | `analyze` | `-fanalyzer` reports a leak on the error path and a use after free of `r`. |

Also confirm: `probe_ubsan` built with `hardened` and run with `2147483647` prints a number and exits zero. That difference is the reason for two builds.

## Time

Half a day, once.
