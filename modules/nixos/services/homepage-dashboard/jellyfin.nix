enable: servicePort: reverseProxyPort:
let
  inherit (builtins) toString;
in
if enable then
  {
    Jellyfin = {
      icon = "jellyfin.png";
      href = "https://localhost:${toString reverseProxyPort}";
      ping = "http://127.0.0.1:${toString servicePort}";
      description = "Free media server for organizing and streaming your personal media.";
      # widget = {
      #   type = "jellyfin";
      #   url = "";
      #   key = "apikey";
      #   enableBlocks = true;
      #   enableNowPlaying = true;
      #   enableUser = false;
      #   expandOneStreamToTwoRows = false;
      # };
    };
  }
else
  { }
