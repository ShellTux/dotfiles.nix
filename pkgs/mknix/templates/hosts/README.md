# HOST_NAME

![GOD_NAME](GOD_IMAGE_URL)

## Install nixos on a remote machine

```sh
nixos-anywhere test --flake .#HOST_NAME --vm-test
nixos-anywhere test --flake .#HOST_NAME --target-host root@<ip address>
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
nixos-rebuild switch --flake .#HOST_NAME --sudo
# Build locally, activate remotely
nixos-rebuild switch --flake .#HOST_NAME --target-host <user>@<ip address> --sudo
# Build and activate remotely
nixos-rebuild switch --flake .#HOST_NAME --build-host <user>@<ip address> --target-host <user>@<ip address> --sudo
```

## Secrets keys

- Install sops age key at location specified `sops.age.keyFile`:

```sh
$ nix repl
nix-repl> :lf .
outputs.nixosConfigurations.HOST_NAME.config.sops.age.keyFile
```
