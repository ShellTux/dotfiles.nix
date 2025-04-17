# laptop

## Install nixos on a remote machine

```sh
nixos-anywhere test --flake .#laptop --vm-test
nixos-anywhere test --flake .#laptop --target-host root@<ip address>
ssh-keygen -R <ip address>
```

## Build nixos machine

> [!NOTE]
> For building in a remote machine you might need to force request a tty, with
> `NIX_SSHOPTS='-o RequestTTY=force'`.

> [!IMPORTANT]
> For the remote ssh user, if not root, make sure to add it to the
> `nix.settings.trusted-users` list.

```sh
# Local machine
nixos-rebuild switch --flake .#laptop --sudo
# Build locally, activate remotely
nixos-rebuild switch --flake .#laptop --target-host <user>@<ip address> --sudo
# Build and activate remotely
nixos-rebuild switch --flake .#laptop --build-host <user>@<ip address> --target-host <user>@<ip address> --sudo
# List generations
nixos-rebuild list-generations --flake .#laptop
```

## Secrets keys

- Install sops age key at location specified `sops.age.keyFile`:

```sh
$ nix repl
nix-repl> :lf .
outputs.nixosConfigurations.laptop.config.sops.age.keyFile
```
