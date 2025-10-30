enable: servicePort: reverseProxyPort:
let
  inherit (builtins) toString;
in
if enable then
  {
    Vaultwarden = {
      icon = "vaultwarden.png";
      href = "https://localhost:${toString reverseProxyPort}";
      ping = "http://127.0.0.1:${toString servicePort}";
      description = "Self-hosted password manager for securely storing passwords and notes.";
    };
  }
else
  { }
