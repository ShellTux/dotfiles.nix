{ pkgs, flake-pkgs, ... }:
{
  imports = [
    ./config
    ./services.crypt.nix
  ];

  users.users.admin = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "ssh-users"
      "wheel" # Enable ‘sudo’ for the user.
    ];
    initialPassword = "123456";
  };

  services.openssh.settings = {
    AllowGroups = [ "ssh-users" ];
    PermitRootLogin = "no";
    PasswordAuthentication = true;
  };

  environment = {
    variables = {
      TERM = "screen-256color";
    };

    systemPackages = [
      pkgs.bat
      pkgs.btop
      pkgs.cowsay
      pkgs.curl
      pkgs.fastfetch
      pkgs.htop
      pkgs.lolcat
      pkgs.net-tools
      pkgs.tldr
      pkgs.tmux
      pkgs.vim
    ]
    ++ [
      flake-pkgs.ipa
    ];
  };

  nix.settings.trusted-users = [ "admin" ];

  programs = {
    bash.enable = true;
    htop.enable = true;
    nh.enable = true;
    rust-motd.enable = true;
    tmux.enable = true;
    vim.enable = true;
    yazi.enable = true;
  };

  system.stateVersion = "25.05";
}
