# This module generates the interactive Zsh environment and declares the tools
# it invokes. It retains the existing Oh My Zsh plugins and embedded SSH helpers.
{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      bat
      dtc
      less
      openssh
    ];

    # Home Manager's session setup adds this before an interactive Zsh starts,
    # so the managed helper scripts remain available without editing PATH by hand.
    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # Keep generated Zsh files under XDG config. Home Manager installs a small
    # ~/.zshenv that points Zsh here before it looks for ~/.zshrc.
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      path = "$HOME/.zsh_history";
      size = 2000;
      save = 2000;
      append = true;
      share = false;
      ignoreSpace = false;
      ignoreAllDups = true;
    };
    sessionVariables = {
      CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
      EDITOR = "nvim";
    };
    shellAliases = {
      ls = "ls --color -lh --group-directories-first";
      vim = "nvim";
      log = "nvim + ~/local/notes/log.md";
      cdh = ''cd "$(git rev-parse --show-toplevel)"'';
      cat = "bat --paging=never -p";

      # Embedded targets regularly regenerate their SSH host keys. These aliases
      # intentionally bypass host verification for that specific workflow.
      lscp = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
      lssh = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
    };
    setOptions = [ "NO_BEEP" "NO_HIST_VERIFY" ];
    initContent = ''
      bindkey -s '^F' 'tmux-sessionizer\n'

      cdhh() {
        local directory
        directory=$(git rev-parse --show-superproject-working-tree 2>/dev/null)
        if [[ -z "$directory" ]]; then
          directory=$(git rev-parse --show-toplevel) || return
        fi
        cd "$directory"
      }

      dtb2dts() {
        local dtb=$1
        local dts=$2

        dtc -I dtb -O dts -o "$dts" "$dtb"
      }
    '';
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "fzf" "colored-man-pages" ];
    };
  };

  programs.fzf = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
