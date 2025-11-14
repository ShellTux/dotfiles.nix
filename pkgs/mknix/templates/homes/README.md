# USERNAME

## Activate home-manager profile

```sh
home-manager switch --flake .
# List generations
home-manager generations
```

## Secrets keys

1. First get sops age key file location

```sh
$ nix repl
nix-repl> :lf .
outputs.homeConfigurations.USERNAME.config.sops.age.keyFile
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
+  - &USERNAME agepublickey_USERNAME
 creation_rules:
   - path_regex: homes/name/secrets\.(yaml|json|env|ini)$
     key_groups:
     - age:
       - *name
+  - path_regex: homes/USERNAME/secrets\.(yaml|json|env|ini)$
+    key_groups:
+    - age:
+      - *USERNAME
```

6. Create `secrets.yaml`

Create with the user to edit files to create `secrets.yaml` with correct permissions.

```sh
$ sops homes/USERNAME/secrets.yaml
```

After creating the `secrets.yaml` file, to edit:

```sh
$ sops edit homes/USERNAME/secrets.yaml
$ sudo -E SOPS_AGE_KEY_FILE=<key.txt> sops edit homes/USERNAME/secrets.yaml # If you need additional permissions to read the file
```

7. Update Nix configuration to provide your `secrets.yaml`

```nix
sops.defaultSopsFile = ./secrets.yaml;
```
