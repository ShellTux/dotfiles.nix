{ ... }:
{
  plugins.rustaceanvim = {
    enable = true;
    settings = {
      dap = {
        autoloadConfigurations = true;
      };

      server = {
        # cmd = [ (lib.getExe pkgs.rust-analyzer) ];
        default_settings = {
          rust-analyzer = {
            cargo = {
              buildScripts.enable = true;
              features = "all";
            };

            diagnostics = {
              enable = true;
              styleLints.enable = true;
            };

            checkOnSave = true;
            check = {
              command = "clippy";
              extraArgs = [
                "--"
                "--no-deps"
                "-Dclippy::correctness"
                "-Dclippy::complexity"
                "-Wclippy::perf"
                "-Wclippy::pedantic"
              ];
              features = "all";
            };

            files = {
              excludeDirs = [
                ".cargo"
                ".direnv"
                ".git"
                "node_modules"
                "target"
              ];
            };

            inlayHints = {
              bindingModeHints.enable = true;
              closureStyle = "rust_analyzer";
              closureReturnTypeHints.enable = "always";
              discriminantHints.enable = "always";
              expressionAdjustmentHints.enable = "always";
              implicitDrops.enable = true;
              lifetimeElisionHints.enable = "always";
              rangeExclusiveHints.enable = true;
            };

            procMacro = {
              enable = true;
            };

            rustc.source = "discover";
          };
        };
      };
    };
  };

}
