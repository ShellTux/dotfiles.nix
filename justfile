#!/usr/bin/env just --justfile

hostname := `hostname`

@default:
  just --list

[linux]
nixos COMMAND="switch" HOST=hostname:
  nixos-rebuild {{COMMAND}} --sudo --flake .#{{HOST}}

home-manager COMMAND="switch":
  home-manager {{COMMAND}} --flake .

alias gc := garbage-collect
garbage-collect:
  nix-collect-garbage --delete-older-than 7d
  nix-store --gc
  nix-store --optimise

alias up := update
update:
  nix flake update
