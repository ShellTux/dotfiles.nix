#!/bin/sh
set -e

# shellcheck disable=SC2068
$@ --help | bat --language=help --style=plain
