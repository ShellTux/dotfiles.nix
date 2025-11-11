{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) mapAttrs;
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    getExe
    filterAttrs
    ;
  inherit (lib.types) bool;

  figlet = getExe pkgs.figlet;
  hostname = getExe pkgs.hostname;
  lolcat = getExe pkgs.lolcat;

  cfg = config.programs.rust-motd;
in
{
  options.programs.rust-motd = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.rust-motd = {
      order = [
        "uptime"
        "global"
        "service_status"
        "last_login"
        "memory"
        "filesystems"
        "load_avg"
        "banner"
      ];
      settings = {
        uptime.prefix = mkDefault "Up";
        filesystems = mkDefault (config.fileSystems |> mapAttrs (mount: _: mount));
        memory.swap_pos = mkDefault "below";
        last_login = mkDefault (
          config.users.users |> filterAttrs (_: userConfig: userConfig.isNormalUser) |> mapAttrs (_: _: 3)
        );
        load_avg.format = "Load (1, 5, 15 min.): {one:.02}, {five:.02}, {fifteen:.02}";
        banner = {
          color = "green";
          command = ''printf 'Servidor %s\n' "$(${hostname})" | ${figlet} -f slant | ${lolcat}'';
        };
      };
    };
  };
}
