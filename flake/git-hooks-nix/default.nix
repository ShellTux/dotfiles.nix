_: {
  perSystem =
    { pkgs, lib, ... }:
    let
      inherit (lib) getExe getExe';

      gitleaks = getExe pkgs.gitleaks;
    in
    {
      pre-commit.settings.hooks = {
        nixfmt.enable = true;
        shellcheck = {
          enable = true;
          excludes = [
            "^pkgs/mknix/completions/"
            ".envrc"
          ];
        };
        # pre-commit-ensure-sops.enable = true;
        # ripsecrets.enable = true;
        # trufflehog.enable = true;

        gitleaks-docker = {
          enable = false;

          name = "Detect hardcoded secrets";
          description = "Detect hardcoded secrets using Gitleaks";
          entry = "gitleaks git --pre-commit --redact --staged --verbose";
          language = "docker_image";
          pass_filenames = false;
        };

        gitleaks-system = {
          enable = true;

          name = "Detect hardcoded secrets";
          description = "Detect hardcoded secrets using Gitleaks";
          entry = "${gitleaks} git --pre-commit --redact --staged --verbose";
          language = "system";
          pass_filenames = false;
        };

        flake-check-after-lock-update = {
          enable = true;

          entry = getExe' (pkgs.writeShellScriptBin "flake-build-validation" ''
            set -euo pipefail

            exit 0

            if git diff --cached --name-only | grep --quiet --line-regexp flake.lock
            then
              nix flake check
            fi
          '') "flake-build-validation";

          language = "system";
          pass_filenames = false;
        };

      };
    };
}
