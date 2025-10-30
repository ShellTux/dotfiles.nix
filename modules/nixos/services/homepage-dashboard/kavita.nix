enable: servicePort: reverseProxyPort:
let
  inherit (builtins) toString;
in
if enable then
  {
    Kavita = {
      icon = "kavita.png";
      ping = "http://127.0.0.1:${toString servicePort}";
      href = "https://localhost:${toString reverseProxyPort}";
      description = "Kavita is an open-source app for managing and reading manga, comics, and ebooks.";
      # widget = {
      #   type = "kavita";
      #   url = "";
      #   key = "";
      # };
    };
  }
else
  { }
