# HOST_NAME

![GOD_NAME](GOD_IMAGE_URL)

## Install nixos on a remote machine

```sh
nixos-anywhere --flake .#HOST_NAME --vm-test
nixos-anywhere --flake .#HOST_NAME --target-host root@<ip address>
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

1. First get sops age key file location

```sh
$ nix repl
nix-repl> :lf .
outputs.nixosConfigurations.HOST_NAME.config.sops.age.keyFile
```

2. Create output directory

```sh
$ mkdir --parents "$(dirname "<key.txt>")"
```

3. Generate sops key file

```sh
$ age-keygen -o "<key.txt>"
```

4. Get public key

```sh
$ age-keygen -y "<key.txt>"
```

5. Update `.sops.yaml`

```diff
@@ -2,9 +2,14 @@
 # age-keygen --output <key.txt>
 # age-keygen -y <key.txt> # To get public key
 keys:
   - &name agepublickey_name
+  - &HOST_NAME agepublickey_HOST_NAME
 creation_rules:
   - path_regex: hosts/name/secrets\.(yaml|json|env|ini)$
     key_groups:
     - age:
       - *name
+  - path_regex: hosts/HOST_NAME/secrets\.(yaml|json|env|ini)$
+    key_groups:
+    - age:
+      - *HOST_NAME
```

6. Create `secrets.yaml`

Create with the user to edit files to create `secrets.yaml` with correct permissions.

```sh
$ sops hosts/HOST_NAME/secrets.yaml
```

After creating the `secrets.yaml` file, to edit:

```sh
$ sops edit hosts/HOST_NAME/secrets.yaml
$ sudo -E SOPS_AGE_KEY_FILE=<key.txt> sops edit hosts/HOST_NAME/secrets.yaml # If you need additional permissions to read the file
```

7. Update Nix configuration to provide your `secrets.yaml`

```nix
sops.defaultSopsFile = ./secrets.yaml;
```
