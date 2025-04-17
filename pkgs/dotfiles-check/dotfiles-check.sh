#!/bin/sh
set -e

usage() {
  echo "Usage: $0"
  exit 1
}

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

success_profiles=
failed_profiles=

# shellcheck disable=SC2043
for profile in laptop nixos-vm
do
  (set -x; nixos-rebuild dry-build --flake "$PWD#$profile") \
    && success_profiles="$success_profiles nixos#$profile" \
    || failed_profiles="$failed_profiles nixos#$profile"
done

# shellcheck disable=SC2043
for profile in luisgois
do
  (set -x; home-manager build --no-out-link --flake "$PWD#$profile") \
    && success_profiles="$success_profiles home-manager#$profile" \
    || failed_profiles="$failed_profiles home-manager#$profile"
done

printf "\033[32mSuccessful profiles\033[0m:\n"
for profile in $success_profiles
do
  echo "  - $profile"
done

echo

printf "\033[31mFailed profiles\033[0m:\n"
for profile in $failed_profiles
do
  echo "  - $profile"
done

test -z "$failed_profiles"

nix-unit --flake .#tests
