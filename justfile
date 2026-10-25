set unstable
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

user := `whoami`
host := `hostname`

help:
    just --list

nixos_cmd(command, profile, target, build-host, uri, extra) := if command == "repl" {
    "nixos-rebuild repl --flake $(realpath " + uri + ")#" + profile
  } else if target == "localhost" {
    "nixos-rebuild " + command + " " + extra
    + (if build-host != "" { "--build-host " + build-host + " " } else { "" })
    + " --sudo --flake " + uri + "#" + profile
  } else {
    "nixos-rebuild " + command + " " + extra
    + (if build-host != "" { "--build-host " + build-host + " " } else { "" })
    + " --sudo --target-host " + target + " --flake " + uri + "#" + profile
  }

home_cmd(command, profile, build-host, uri, extra) := if command == "repl" {
    "home-manager repl --flake $(realpath " + uri + ")#" + profile
  } else {
    "home-manager " + command + " " + extra
    + (if build-host != "" { "--build-host " + build-host + " " } else { "" })
    + " --flake " + uri + "#" + profile
  }

[arg("profile", long="profile", short)]
[arg("target", long="target", short)]
[arg("build-host", long="build-host", short)]
[arg("uri", long="uri", short)]
[arg("extra", long="extra", short)]
nixos command="build" profile=host target="localhost" build-host="" uri="." extra="":
    {{ nixos_cmd(command, profile, target, build-host, uri, extra) }}

[arg("profile", long="profile", short)]
[arg("build-host", long="build-host", short)]
[arg("uri", long="uri", short)]
[arg("extra", long="extra", short)]
home command="build" profile=user build-host="" uri="." extra="":
    {{ home_cmd(command, profile, build-host, uri, extra) }}

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
