user     := $(shell whoami)
hostname := $(shell hostname)

export NIX_SSHOPTS := -t

.PHONY: default
default:

command    := switch
profile    :=
target     := localhost
uri        := .
extra-args :=
.PHONY: nixos
nixos:
ifeq ($(target), localhost)
	nixos-rebuild $(command) \
		$(extra-args) \
		--sudo \
		--flake $(uri)\#$(or $(profile), $(hostname))
else
	nixos-rebuild $(command) \
		$(extra-args) \
		--sudo \
		--target-host $(target) \
		--flake $(uri)\#$(or $(profile), $(hostname))
endif

nixos-repl:
	nixos-rebuild repl \
		--flake $(shell realpath $(uri))\#$(or $(profile), $(hostname))

command    := switch
extra-args :=
.PHONY: home-manager
home-manager:
ifeq ($(target), localhost)
	home-manager $(command) \
		$(extra-args) \
		--flake $(uri)\#$(or $(profile),$(user))
else
	home-manager $(command) \
		$(extra-args) \
		--flake $(uri)\#$(or $(profile), $(user))
endif

home-repl:
	home-manager repl \
		--flake $(shell realpath $(uri))\#$(or $(profile), $(user))

inspect:
	nix-inspect

.PHONY: test
test:
	$(MAKE) nixos command=build
	$(MAKE) home-manager command=build
	@printf '\033[32m%s\033[0m\n' PASSED

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
