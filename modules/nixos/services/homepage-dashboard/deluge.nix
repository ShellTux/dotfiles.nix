enable: servicePort: reverseProxyPort:
let
  inherit (builtins) toString;
in
if enable then
  {
    Deluge = {
      icon = "deluge.png";
      href = "https://localhost:${toString reverseProxyPort}";
      ping = "http://127.0.0.1:${toString servicePort}";
      description = "Deluge is a lightweight, Free Software, cross-platform BitTorrent client.";
      # widget = {
      #   type = "deluge";
      #   url = "todo";
      #   password = "password";
      # };
    };
  }
else
  { }
