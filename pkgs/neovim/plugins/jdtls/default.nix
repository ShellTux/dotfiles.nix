{
  programs.nixvim.plugins.jdtls.settings.cmd = [
    "${jdtls}"
    "-data"
    "${config.xdg.cacheHome}/jdtls/workspace"
    "-configuration"
    "${config.xdg.cacheHome}/jdtls/config"
  ];
}
