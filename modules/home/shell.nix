# This module generates the interactive Zsh environment and declares the tools
# it invokes. It retains the existing Oh My Zsh plugins and embedded SSH helpers.
{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      bat
      dtc
      eza
      fd
      less
      openssh
    ];

    # Home Manager's session setup adds this before an interactive Zsh starts,
    # so the managed helper scripts remain available without editing PATH by hand.
    sessionPath = [ "$HOME/.local/bin" ];
    # All shells and desktop applications use the single user-session agent.
    sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";

  };

  # Do not spawn an agent for each terminal. A user service provides one stable
  # socket for shells, graphical applications, and long-lived tmux sessions.
  systemd.user.services.ssh-agent = {
    Unit.Description = "SSH key agent";
    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.socket";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };

  programs.bash = {
    enable = true;
    shellAliases.find = "fd";
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
      ls = "eza --color=always --long --group --group-directories-first";
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
      # Home Manager's generated session script may be skipped by terminal
      # descendants, so set the stable user-agent socket unconditionally.
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

      bindkey -s '^F' 'workdeck\n'

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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
