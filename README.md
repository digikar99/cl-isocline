isocline and isocline-repl (Common Lisp)
---

[Isocline](https://github.com/daanx/isocline) is an alternative to
libreadline, libedit and the likes, that is

-   MIT licensed
-   Pure C
-   Portable across Unix, Windows, MacOS
-   Supports multiline editing out of the box
-   ... and much more ...

This means it works as an awesome portable repl for Common Lisp, across
operating systems and lisp implementations.

The current repository contains source code for version 1.0.9 of
Isocline, along with [lisp bindings](lisp/isocline.lisp) and a [simple
repl](lisp/isocline-repl.lisp).

![](demo.gif)

# Installation

## Binaries

Currently standalone binaries are available for Windows. See the
[Releases](https://github.com/digikar99/cl-isocline/releases/).

## Compiling from source

### Quicklisp client

[rudolfochrist/ql-https](https://github.com/rudolfochrist/ql-https) is a
quicklisp client variant that uses https.

```sh
curl https://raw.githubusercontent.com/rudolfochrist/ql-https/master/install.sh | bash
```

### Ultralisp

```lisp
;; ql-https will upgrade the URLs from http to https
(ql-dist:install-dist "http://dist.ultralisp.org/" :prompt nil)
```

### isocline-repl

If you have ultralisp installed, then you can

```lisp
(ql:quickload "isocline-repl")
(isocline-repl:run)
```

### Binary

The following should create a `cl-isocline-repl` in the root
directory of `isocline-repl`.

```lisp
(asdf:make "isocline-repl")
```
