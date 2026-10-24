set unstable
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

user := `whoami`
host := `hostname`

help:
    just --list

nixos_cmd(command, profile, target, uri, extra) := if command == "repl" {
    "nixos-rebuild repl --flake $(realpath " + uri + ")#" + profile
  } else if target == "localhost" {
    "nixos-rebuild " + command + " " + extra + "--sudo --flake " + uri + "#" + profile
  } else {
    "nixos-rebuild " + command + " " + extra + "--sudo --target-host " + target + " --flake " + uri + "#" + profile
  }

home_cmd(command, profile, uri, extra) := if command == "repl" {
    "home-manager repl --flake $(realpath " + uri + ")#" + profile
  } else {
    "home-manager " + command + " " + extra + " --flake " + uri + "#" + profile
  }

[arg("profile", long="profile", short)]
[arg("target", long="target", short)]
[arg("uri", long="uri", short)]
[arg("extra", long="extra", short)]
nixos command="build" profile=host target="localhost" uri="." extra="":
    {{ nixos_cmd(command, profile, target, uri, extra) }}

[arg("profile", long="profile", short)]
[arg("uri", long="uri", short)]
[arg("extra", long="extra", short)]
home command="build" profile=user uri="." extra="":
    {{ home_cmd(command, profile, uri, extra) }}

inspect:
    nix-inspect

test:
    just nixos build
    just home build
    @printf '\033[32m%s\033[0m\n' PASSED

check:
    nix flake check --all-systems --no-build

gc:
    nix-collect-garbage --delete-older-than 7d
    nix-store --gc
    nix-store --optimise

update:
    nix flake update

up: update
