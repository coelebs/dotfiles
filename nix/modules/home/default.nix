# This module owns the primary user's portable configuration. Native Home
# Manager options generate Bash while files that need their own format remain
# sourced from the repository root.
{ dotfiles, lib, omarchyShell, pinentryOmarchy, pkgs, pkgsUnstable, primaryUser, ... }:

{
  imports = [ ./shell.nix ./tmux.nix ];

  home = {
    username = primaryUser;
    homeDirectory = "/home/${primaryUser}";

    # Update only when deliberately adopting Home Manager behavior changes.
    stateVersion = "26.05";

    packages = with pkgs; [
      aerc
      bambu-studio
      calibre
      codex
      git
      ghostty
      htop
      lua-language-server
      nchat
      neovim
      rapid-photo-downloader
      ripgrep
      stylua
      unzip
      pkgsUnstable.opencode
      pinentryOmarchy
      rbw
    ];
  };

  # `dotfiles` is the repository root source input. Home Manager owns these
  # Stow targets after activation. `force` replaces only the old Stow links;
  # their source files remain in this repository.
  home.file = {
    ".local/bin".source = dotfiles + "/bin/.local/bin";
  };

  xdg.configFile."nvim".source = dotfiles + "/nvim/.config/nvim";
  xdg.configFile."omarchy/hooks/theme-set.d/aerc-theme-omarchy" = {
    source = dotfiles + "/bin/.local/bin/aerc-theme-omarchy";
    executable = true;
    force = true;
  };
  xdg.configFile."omarchy/plugins/coelebs.pinentry".source = "${pinentryOmarchy}/share/omarchy/plugins/coelebs.pinentry";

  home.activation.enableOmarchyPinentry = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${omarchyShell}/bin/omarchy-shell shell setPluginEnabled vin.pinentry false >/dev/null 2>&1 || true
    # Prefer Omarchy's own IPC: it enables the plugin in the running shell and
    # persists the entry to shell.json in one step.
    if ${omarchyShell}/bin/omarchy-shell shell enablePlugin coelebs.pinentry true >/dev/null 2>&1; then
      enabled=1
    else
      enabled=0
    fi
    # Fallback for a fresh machine where the shell is not running yet.
    if [[ $enabled -eq 0 ]]; then
      state="$HOME/.config/omarchy/shell.json"
      if [[ ! -f $state ]]; then
        install -Dm644 "${omarchyShell}/share/omarchy/config/omarchy/shell.json" "$state"
      fi
      temporary=$(mktemp "$state.XXXXXX")
      ${pkgs.jq}/bin/jq '
        .plugins = ((.plugins // []) | if type == "array" then . else [] end
          | map(select(.id != "vin.pinentry"))
          | if any(.[]; .id == "coelebs.pinentry") then . else . + [{ "id": "coelebs.pinentry" }] end)
      ' "$state" > "$temporary"
      mv "$temporary" "$state"
    fi
    # Drop the legacy vin.pinentry entry from shell.json when the IPC route
    # succeeded; jq still runs in the fallback branch above.
    state="$HOME/.config/omarchy/shell.json"
    if [[ -f $state ]]; then
      temporary=$(mktemp "$state.XXXXXX")
      ${pkgs.jq}/bin/jq '
        if type == "object" and (.plugins // null | type == "array") then
          .plugins |= map(select(.id != "vin.pinentry"))
        else . end
      ' "$state" > "$temporary"
      mv "$temporary" "$state"
    fi
    ${pkgs.rbw}/bin/rbw config set pinentry "${pinentryOmarchy}/bin/pinentry-omarchy"
  '';
  # Calibre persists this library choice in its writable preferences.
  xdg.desktopEntries."calibre-gui" = {
    name = "Calibre";
    genericName = "E-book library management";
    exec = "calibre --with-library /mnt/nas/boeken %U";
    icon = "calibre-gui";
    terminal = false;
    categories = [ "Office" "Viewer" ];
    mimeType = [ "application/epub+zip" "application/x-mobipocket-ebook" ];
  };

}
