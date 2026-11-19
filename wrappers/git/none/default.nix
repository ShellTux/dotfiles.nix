{ lib, config, ... }:
lib.mkIf (config.flavour == "none") { }
