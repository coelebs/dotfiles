# This module is the explicit system-profile package selection. Omarchy-owned
# runtime tools live in omarchy.nix, leaving this list for general user tools.
{ pkgs, pkgsUnstable, ... }:

{
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    neovim
    pkgsUnstable.opencode
    ghostty
    quickshell
    git
    codex
    stow
    ripgrep
    lua-language-server
    stylua
    starship
    unzip
    rapid-photo-downloader
    tmux
    fzf
    aerc
  ];
}
