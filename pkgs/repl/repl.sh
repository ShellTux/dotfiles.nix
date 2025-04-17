#!/bin/sh
set -e

nix repl --extra-experimental-features pipe-operators --expr "builtins.getFlake \"$PWD\""
