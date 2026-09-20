# This module configures system-supported user applications whose NixOS options
# do more than merely install a package, such as Firefox and LocalSend.
{
  programs.firefox.enable = true;

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
}
