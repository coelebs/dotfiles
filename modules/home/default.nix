# This module owns the primary user's portable configuration. Native Home
# Manager options generate shell configuration; helper scripts live beside it.
{ lib, omarchyShell ? null, opencode2, pinentryOmarchy, pkgs, pkgsUnstable, primaryUser, workdeck, onNixOS ? true, ... }:

{
  imports = [ ./shell.nix ./tmux.nix ./neovim.nix ./go.nix ];

  home = {
    username = primaryUser;
    homeDirectory = "/home/${primaryUser}";

    # Update only when deliberately adopting Home Manager behavior changes.
    stateVersion = "26.05";

    packages = (with pkgs; [
      aerc
      bambu-studio
      calibre
      digikam
      (symlinkJoin {
        name = "darktable";
        paths = [ darktable ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/darktable --set XCURSOR_SIZE 38
        '';
      })
      ghostty
      htop
      mpv
      nchat
      rapid-photo-downloader
      ripgrep
      stylua
      unzip
      # Use the pinned unstable Nixpkgs for these tools.
      pkgsUnstable.tuicr
      pkgsUnstable.opencode
      pkgsUnstable.codex
      pkgsUnstable.t3code
      opencode2
      rbw
    ]) ++ [ pinentryOmarchy workdeck ];
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Vincent Kriek";
        email = "vincent@coelebs.dev";
      };
      alias.lg = "log --graph --oneline --decorate --all";
      init.defaultBranch = "master";
      pull.rebase = true;
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
      };
      commit.verbose = true;
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "-version:refname";
      rerere = {
        enabled = true;
        autoupdate = true;
      };
    };
  };

  # Home Manager deploys the portable helper scripts.
  home.file = {
    ".local/bin" = {
      source = ./bin;
      recursive = true;
    };
  };

  xdg.configFile."omarchy/hooks/theme-set.d/aerc-theme-omarchy" = {
    source = ./bin/aerc-theme-omarchy;
    executable = true;
    force = true;
  };
  xdg.configFile."omarchy/plugins/coelebs.pinentry" = {
    source = "${pinentryOmarchy}/share/omarchy/plugins/coelebs.pinentry";
  };

  home.activation.enableOmarchyPinentry = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Arch may not have Omarchy installed yet. In that case, leave rbw's
    # existing pinentry setting alone; the plugin link can wait until later.
    shell=${if onNixOS then "${omarchyShell}/bin/omarchy-shell" else "omarchy-shell"}
    if command -v "$shell" >/dev/null 2>&1; then
      "$shell" shell setPluginEnabled vin.pinentry false >/dev/null 2>&1 || true
      "$shell" shell rescanPlugins >/dev/null 2>&1 || true
      # Prefer Omarchy's own IPC: it enables the plugin in the running shell and
      # persists the entry to shell.json in one step.
      if "$shell" shell enablePlugin coelebs.pinentry true >/dev/null 2>&1; then
        enabled=1
      else
        enabled=0
      fi
      # Fallback for a fresh machine where the shell is not running yet.
      if [[ $enabled -eq 0 ]]; then
        state="$HOME/.config/omarchy/shell.json"
        if [[ ! -f $state ]]; then
          default_state=${if onNixOS then "${omarchyShell}/share/omarchy/config/omarchy/shell.json" else "/usr/share/omarchy/config/omarchy/shell.json"}
          if [[ -f $default_state ]]; then
            install -Dm644 "$default_state" "$state"
          fi
        fi
        if [[ -f $state ]]; then
          temporary=$(mktemp "$state.XXXXXX")
          ${pkgs.jq}/bin/jq '
        .plugins = ((.plugins // []) | if type == "array" then . else [] end
          | map(select(.id != "vin.pinentry"))
          | if any(.[]; .id == "coelebs.pinentry") then . else . + [{ "id": "coelebs.pinentry" }] end)
          ' "$state" > "$temporary"
          mv "$temporary" "$state"
        fi
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
    fi
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

  # The Nix package provides the executable but no .desktop file.
  xdg.desktopEntries."rapid-photo-downloader" = {
    name = "Rapid Photo Downloader";
    genericName = "Photo and video downloader";
    exec = "${pkgs.rapid-photo-downloader}/bin/rapid-photo-downloader";
    icon = "camera-photo";
    terminal = false;
    categories = [ "Graphics" "Photography" ];
  };

}
