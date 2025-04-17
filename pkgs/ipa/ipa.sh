#!/bin/sh
set -e

usage() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo
  echo "Options:"
  echo "  -P, --public       Fetch and display public IP addresses"
  echo "  -h, --help         Show this help message and exit"
  echo
  echo "Description:"
  echo "This script retrieves your network's IPv4 and IPv6 addresses."
  echo "By default, it shows local network addresses."
  echo "Using '--public' fetches your public addresses from ifconfig.me."
  echo
  exit 1
}

public=false

for arg
do
  case "$arg" in
    -P | --public) public=true ;;
    -h | --help) usage ;;
    *) usage "Unknown flag: $arg" ;;
  esac
done

if $public
then
  ipv4="$(curl --ipv4 --silent ifconfig.me || true)"
  ipv6="$(curl --ipv6 --silent ifconfig.me || true)"
else
  ipv4="$(ip -oneline address show \
    | cut --delimiter=' ' --fields=2,7 \
    | grep --invert-match : \
    | column --table)"
  ipv6="$(ip -oneline address show \
    | cut --delimiter=' ' --fields=2,7 \
    | grep : \
    | column --table)"
fi

case "$(seq 1 20 | sort --random-sort | head -1)" in
  1)
    echo "IPv4:"
    echo "$ipv4" | cowsay -n

    echo

    echo "IPv6:"
    echo "$ipv6" | cowsay -n
    ;;
  *)
    echo "IPv4:"
    echo "$ipv4"

    echo

    echo "IPv6:"
    echo "$ipv6"
    ;;
esac

