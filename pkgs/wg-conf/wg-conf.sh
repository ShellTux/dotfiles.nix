#!/bin/sh
set -e

usage() {
  echo "Usage: $(basename "$0") [CONF]..."
  exit 1
}

qr=false
conf_dir=/etc/wireguard

available_confs="$(find "$conf_dir" -type f -name '*.conf' -printf '%f\n' | sed 's/\.[^.]*$//' | tr '\n' ' ' | sed 's|^[ \t]*||;s|[ \t*]$||')"
confs=

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
  [ "$arg" = --qr ] && qr=true

  if ! (echo "$available_confs" | grep --quiet "$arg")
  then
    echo 'Available confs:'
    echo "$available_confs" | tr ' ' '\n' | sed 's|^|-  |'
    exit 0
  fi

  confs="$confs $arg"
done

[ -z "$confs" ] && usage

for conf in $confs
do
  conf_file="$conf_dir/$conf.conf"
  private_key="$(awk '/PrivateKey/ {print $3}' "$conf_file" | xargs cat)"

  # shellcheck disable=SC2015
  cat "$conf_file" \
    | sed 's|PrivateKey\s*=.*|PrivateKey = '"$private_key"'|' \
    | sed 's|127.0.0.1|'"$(curl --ipv4 --silent ifconfig.me || true)"'|' \
    | ($qr && qrencode --type ansiutf8 || bat --plain --language=conf)
done

