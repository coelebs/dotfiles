# This module manages the active, portable dotfiles without rewriting their
# contents yet. Native Home Manager options can replace individual files after
# this behavior-preserving migration has been used successfully.
{ dotfiles, pkgs, pkgsUnstable, primaryUser, ... }:

{
  home = {
    username = primaryUser;
    homeDirectory = "/home/${primaryUser}";

    # Update only when deliberately adopting Home Manager behavior changes.
    stateVersion = "26.05";

    packages = with pkgs; [
      aerc
      codex
      fzf
      git
      ghostty
      lua-language-server
      neovim
      rapid-photo-downloader
      ripgrep
      starship
      stylua
      tmux
      unzip
      pkgsUnstable.opencode
    ];
  };

  # `dotfiles` is the repository root source input. Home Manager will atomically
  # own these existing Stow targets after activation, so do not run Stow for
  # these packages again.
  home.file = {
    ".alias".source = dotfiles + "/shell/.alias";
    ".bash_profile".source = dotfiles + "/shell/.bash_profile";
    ".bashrc".source = dotfiles + "/shell/.bashrc";
    ".local/bin".source = dotfiles + "/bin/.local/bin";
    ".tmux.conf".source = dotfiles + "/tmux/.tmux.conf";
  };

  xdg.configFile."nvim".source = dotfiles + "/nvim/.config/nvim";
}
