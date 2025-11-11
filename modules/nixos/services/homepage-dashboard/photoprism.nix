enable: servicePort: reverseProxyPort:
let
  inherit (builtins) toString;
in
if enable then
  {
    Photoprism = {
      icon = "photoprism.png";
      href = "https://localhost:${toString reverseProxyPort}";
      ping = "http://127.0.0.1:${toString servicePort}";
      description = "PhotoPrism® is an AI-Powered Photos App for the Decentralized Web. It makes use of the latest technologies to tag and find pictures automatically without getting in your way. You can run it at home, on a private server, or in the cloud.";
      # widget = {
      #   type = "photoprism";
      #   url = "";
      #   username = "admin"; # required only if using username/password
      #   password = "password"; # required only if using username/password
      #   key = ""; # required only if using app passwords
      # };
    };
  }
else
  { }
