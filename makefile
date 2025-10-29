hostname := $(shell hostname)

export NIX_SSHOPTS := -t

.PHONY: default
default:

command := switch
profile := $(hostname)
target  := localhost
uri     := .
.PHONY: nixos
nixos:
ifeq ($(target), localhost)
	nixos-rebuild $(command) \
		--sudo \
		--flake $(uri)\#$(profile)
else
	nixos-rebuild $(command) \
		--sudo \
		--target-host $(target) \
		--flake $(uri)\#$(profile)
endif

command := switch
.PHONY: home-manager
home-manager:
	home-manager $(command) --flake .

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
