{ pkgs, ... }:
{
  imports = [
    # Flavours
    ./none
    ./config1
  ];

  config = {
    package = pkgs.bat;
  };
}
