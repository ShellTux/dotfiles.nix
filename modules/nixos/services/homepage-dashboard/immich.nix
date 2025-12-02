enable: servicePort: reverseProxyPort:
let
  inherit (builtins) toString;
in
if enable then
  {
    Immich = {
      icon = "immich.png";
      ping = "http://127.0.0.1:${toString servicePort}";
      href = "https://localhost:${toString reverseProxyPort}";
      description = "High performance self-hosted photo and video management solution.";
    };
  }
else
  { }
