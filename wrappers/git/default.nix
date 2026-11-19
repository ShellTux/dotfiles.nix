{ ... }:
{
  imports = [
    ./common
    ./none
    ./delta
    ./diff-so-fancy
    ./difftastic
    ./diffr
  ];

  options = {
    # TODO: includeIf
    # TODO: sendemail
  };

  config = { };
}
