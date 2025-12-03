hostname := $(shell hostname)

export NIX_SSHOPTS := -t

.PHONY: default
default:

command    := switch
profile    := $(hostname)
target     := localhost
uri        := .
extra-args :=
.PHONY: nixos
nixos:
ifeq ($(target), localhost)
	nixos-rebuild $(command) \
		--sudo $(extra-args) \
		--flake $(uri)\#$(profile)
else
	nixos-rebuild $(command) \
		--sudo $(extra-args) \
		--target-host $(target) \
		--flake $(uri)\#$(profile)
endif

command    := switch
extra-args :=
.PHONY: home-manager
home-manager:
	home-manager $(command) $(extra-args) --flake .

.PHONY: garbage-collect
garbage-collect:
	nix-collect-garbage --delete-older-than 7d
	nix-store --gc
	nix-store --optimise

.PHONY: gc
gc: garbage-collect

.PHONY: update
update:
	nix flake update

.PHONY: up
up: update
