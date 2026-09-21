# This module owns the primary user's portable configuration. Native Home
# Manager options generate Bash while files that need their own format remain
# sourced from the repository root.
{ dotfiles, pkgs, pkgsUnstable, primaryUser, ... }:

{
  imports = [ ./shell.nix ./tmux.nix ];

  home = {
    username = primaryUser;
    homeDirectory = "/home/${primaryUser}";

    # Update only when deliberately adopting Home Manager behavior changes.
    stateVersion = "26.05";

    packages = with pkgs; [
      aerc
      codex
      git
      ghostty
      lua-language-server
      neovim
      rapid-photo-downloader
      ripgrep
      stylua
      unzip
      pkgsUnstable.opencode
    ];
  };

  # `dotfiles` is the repository root source input. Home Manager owns these
  # Stow targets after activation. `force` replaces only the old Stow links;
  # their source files remain in this repository.
  home.file = {
    ".local/bin".source = dotfiles + "/bin/.local/bin";
  };

  xdg.configFile."nvim".source = dotfiles + "/nvim/.config/nvim";

}
