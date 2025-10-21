{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) concatStringsSep;
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    getExe
    ;
  inherit (lib.types) bool;

  bat = getExe pkgs.bat;

  cfg = config.programs.fzf;
in
{
  options.programs.fzf = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) (mkDefault {
    programs.fzf = {
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--layout=reverse"
        "--border"
        "--cycle"
        "--info=inline"
      ];
    };

    programs.bash.profileExtra = ''
      source ${./custom.sh}
    '';

    programs.zsh.init.extra = ''
      source ${./custom.sh}
    '';

    home = {
      shellAliases = {
        fzf = ''fzf --preview "${bat} --color=always --style=numbers --line-range=:500 {}"'';
        fzfs = concatStringsSep " " [
          "fzf"
          "--style=full"
          "--input-label=' Input '"
          "--header-label=' File Type '"
          "--preview='${bat} --color=always --style=numbers --line-range=:500 {}'"
          ''
            --bind='result:transform-list-label:
                if [[ -z $FZF_QUERY ]]; then
                  echo " $FZF_MATCH_COUNT items "
                else
                  echo " $FZF_MATCH_COUNT matches for [$FZF_QUERY] "
                fi
                '
          ''
          ''--bind="focus:transform-preview-label:[[ -n {} ]] && printf ' Previewing [%s] ' {}"''
          ''--bind="focus:+transform-header:file --brief {} || echo 'No file selected'"''
          "--bind='ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; git ls-files)'"
          "--color='border:#aaaaaa,label:#cccccc'"
          "--color='preview-border:#9999cc,preview-label:#ccccff'"
          "--color='list-border:#669966,list-label:#99cc99'"
          "--color='input-border:#996666,input-label:#ffcccc'"
          "--color='header-border:#6699cc,header-label:#99ccff'"
        ];
      };
      sessionVariables = {
        FZF_CTRL_T_OPTS = ''
          --walker-skip .git,node_modules,target,.direnv
          --preview '${bat} --color=always --style=numbers --line-range=:500 {}'
          --bind 'ctrl-/:change-preview-window(down|hidden|)'
        '';
      };
    };
  });
}
