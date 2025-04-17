#!/bin/sh
set -e

usage() {
  echo "Usage: $0 <nixos|home-manager> <module name>"
  exit 1
}

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

[ "$#" -lt 2 ] && usage && exit 1

MODULE_TYPE="$1"
MODULE_NAME="$2"
MODULE_DIR=modules/"$MODULE_TYPE"/"$MODULE_NAME"

mkdir --parents "$MODULE_DIR"

# shellcheck disable=SC2001
NIX_MODULE="$(echo "$MODULE_NAME" | sed 's|/|.|g')"

cat <<EOF | (set -x; tee "$MODULE_DIR/default.nix") | bat --style=numbers --pager=never --language=nix
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.$NIX_MODULE;
in
{
  options.$NIX_MODULE = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    $NIX_MODULE = { };
  };
}
EOF
