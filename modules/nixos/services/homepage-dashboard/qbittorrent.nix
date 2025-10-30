enable: servicePort: reverseProxyPort:
let
  inherit (builtins) toString;
in
if enable then
  {
    qBittorrent = {
      icon = "qbittorrent.png";
      href = "https://localhost:${toString reverseProxyPort}";
      ping = "http://127.0.0.1:${toString servicePort}";
      description = "Open-source torrent client for downloading and sharing files.";
      # widget = {
      #   type = "qbittorrent";
      #   url = "todo";
      #   username = cfg.serverConfig.Preferences.WebUI.Username;
      #   password = cfg.serverConfig.Preferences.WebUI.Password_PBKDF2;
      # };
    };
  }
else
  { }
