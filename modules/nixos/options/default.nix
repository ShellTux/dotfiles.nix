{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) str;
in
{
  options.server = {
    domain = mkOption {
      description = "The primary domain for the server. This domain is used to identify the server on the network and is essential for setting up web services, including web applications and APIs. It is also important for managing SSL/TLS certificates and DNS configurations. Ensure the domain is registered and points to the server's IP address.";
      type = str;
      default = "home";
    };
  };
}
