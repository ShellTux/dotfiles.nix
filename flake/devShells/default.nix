_: {
  perSystem =
    {
      config,
      self',
      inputs',
      pkgs,
      system,
      lib,
      ...
    }:
    let
      inherit (builtins) attrValues elem;
      inherit (pkgs) mkShell;
      inherit (lib) getExe filterAttrs;

      additionalPackages =
        config.packages
        |> filterAttrs (
          key: value:
          (elem key [
            "dotfiles-check"
            "mknix"
            "repl"
            "vm"
          ])
        )
        |> attrValues;

      onefetch = getExe pkgs.onefetch;
    in
    {
      devShells.default = mkShell {
        name = "dotfiles.nix";

        packages = [
          pkgs.age
          pkgs.git
          pkgs.git-crypt
          pkgs.gitleaks
          pkgs.git-secrets
          # pkgs.guestfs-tools
          pkgs.just
          pkgs.nh
          pkgs.nix-index
          pkgs.nixos-rebuild
          pkgs.ripsecrets
          pkgs.sops
          pkgs.ssh-to-age
          pkgs.tokei
          pkgs.trufflehog
        ]
        ++ [
          inputs'.nixos-anywhere.packages.nixos-anywhere
          inputs'.home-manager.packages.home-manager
          inputs'.nix-unit.packages.nix-unit
        ]
        ++ additionalPackages
        ++ config.pre-commit.settings.enabledPackages;

        env = {
          NIX_SSHOPTS = "-o RequestTTY=force";
        };

        shellHook = ''
          echo 'Installing pre-commit hooks...'
          ${config.pre-commit.installationScript}
          export FLAKE='.' NH_FLAKE='.'
          ${onefetch} --no-bots
        '';
      };
    };
}
