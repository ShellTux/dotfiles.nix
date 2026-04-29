{ pkgs, ... }:
{
  programs.thunderbird.nativeMessagingHosts = [ pkgs.external-editor-revived ];
}
