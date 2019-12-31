# `libcompat_time32`

## Introduction

This package builds the time32 compat shims from musl 1.2.0+ as a
standalone static (archive) library which can be linked (with
`--whole-archive`) into `LD_PRELOAD` wrapper libraries. This allows
such a library which needs to intercept one or more of the 63
functions replaced by a new time64 version to also intercept the old
time32 symbol, for running legacy time32 binaries, automatically,
without the need to be aware of time ABI differences. Just link it and
everything magically works.

## Building

Create a symlink named `musl` to the root of the musl source tree
(1.2.0+ or git master) elsewhere, or invoke `make` with the `srcdir`
variable set to the location of the musl source tree, e.g.:

    make srcdir=$HOME/src/musl

This assumes you're building on a musl-based system; if not, the `CC`
variable also needs to be set to a musl-targeting cross compiler or
the `musl-gcc` wrapper.

There is no install rule, as where or whether to install it is a
matter of how you're using it.

## Usage

Add `-Wl,--whole-archive -lcompat_time32 -Wl,--no-whole-archive` to
the link command line. Special hacks (like prepending `-Wl,` to
`-lcompat_time32`) may be needed if libtool is intercepting and
mangling the command line.

## How it works

musl's time32 compatibility symbols are not old time32 versions of the
corresponding functions, but thin wrappers around the new time64
functions. By placing a copy of the wrapper into your `LD_PRELOAD`
interceptor library, your interceptor library now defines the symbol
in a way that it gets routed through its own wrapper function.

For example, a call from the application to the legacy time32 `stat`
goes through:

1. `stat` symbol provided by `libcompat_time32.a` in your interceptor
   library

2. `__stat_time64` symbol your interceptor library defines by
   implementing a function named `stat` after including `<sys/stat.h>`

3. `__stat_time64` symbol in `libc.so`, obtained by calling
   `dlsym(RTLD_NEXT, "stat")` (assuming interceptor eventually calls
   the real function)

Without linking `libcompat_time32.a` in, the legacy application's call
to the legacy time32 `stat` function would go to the definition in
`libc.so`, unless the interceptor went through unreasonable hacks to
define a symbol named `stat` and match the legacy structure ABI.
