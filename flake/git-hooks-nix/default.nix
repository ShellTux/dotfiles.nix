_: {
  perSystem = _: {
    pre-commit.settings.hooks = {
      nixfmt.enable = true;
      shellcheck.enable = true;
      # pre-commit-ensure-sops.enable = true;
      # ripsecrets.enable = true;
      # trufflehog.enable = true;

      gitleaks = {
        enable = true;

        name = "Detect hardcoded secrets";
        description = "Detect hardcoded secrets using Gitleaks";
        entry = "gitleaks git --pre-commit --redact --staged --verbose";
        language = "golang";
        pass_filenames = false;
      };

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
        entry = "gitleaks git --pre-commit --redact --staged --verbose";
        language = "system";
        pass_filenames = false;
      };

    };
  };
}
