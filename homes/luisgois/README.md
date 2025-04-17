# luisgois

## Activate home-manager profile

```sh
home-manager switch --flake .
# List generations
home-manager generations
```

## Secrets keys

- Install sops age key at location specified `sops.age.keyFile`:

```sh
$ nix repl
nix-repl> :lf .
outputs.homeConfigurations.luisgois.config.sops.age.keyFile
```
