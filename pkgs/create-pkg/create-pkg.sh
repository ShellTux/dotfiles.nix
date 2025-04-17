#!/bin/sh
set -e

usage() {
  echo "Usage: $0 <package name>"
  exit 1
}

[ "$#" -lt 1 ] && usage && exit 1

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

PACKAGE_NAME="$1"
PACKAGE_DIR=pkgs/"$PACKAGE_NAME"

mkdir --parents "$PACKAGE_DIR"

cat <<EOF | (set -x; tee "$PACKAGE_DIR/default.nix") | bat --style=numbers --pager=never --language=nix
{ writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "$PACKAGE_NAME";

  runtimeInputs = [ ];

  text = readFile ./$PACKAGE_NAME.sh;
}
EOF

echo

cat <<EOF | (set -x; tee "$PACKAGE_DIR/$PACKAGE_NAME.sh") | bat --style=numbers --pager=never
#!/bin/sh
set -e

usage() {
  echo "Usage: \$0"
  exit 1
}

for arg
do
  [ "\$arg" = -h ] && usage
  [ "\$arg" = --help ] && usage
done
EOF

chmod u+x "$PACKAGE_DIR/$PACKAGE_NAME.sh"
