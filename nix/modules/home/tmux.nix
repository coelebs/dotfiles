{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 5000;
    keyMode = "vi";
    shortcut = "a";
    terminal = "screen-256color";
    extraConfig = ''
       set -ga terminal-overrides ",xterm-256color*:Tc,kitty:Tc"
       set -g status-style 'bg=default,fg=default'
      set -g focus-events on

      bind r source-file ~/.config/tmux/tmux.conf
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

      # Vim-like pane switching.
      bind -r ^ last-window
      bind-key -n M-1 select-window -t 1
      bind-key -n M-2 select-window -t 2
      bind-key -n M-3 select-window -t 3
      bind-key -n M-4 select-window -t 4
      bind-key -n M-5 select-window -t 5
      bind-key -n M-6 select-window -t 6
      bind-key -n M-7 select-window -t 7
      bind-key -n M-8 select-window -t 8
      bind-key -n M-9 select-window -t 9
      bind-key -n M-h select-pane -L
      bind-key -n M-j select-pane -D
      bind-key -n M-k select-pane -U
      bind-key -n M-l select-pane -R
      set-option -g repeat-time 0

      set -g status-left-length 40
      bind-key -n C-f new-window "tmux-sessionizer"

      # Start new splits in the active pane's working directory.
      bind '"' split-window -v -c '#{pane_current_path}'
      bind % split-window -h -c '#{pane_current_path}'

      set -g extended-keys
    '';
  };

  xdg.configFile."omarchy/hooks/theme-set.d/tmux-theme-omarchy" = {
    executable = true;
    force = true;
    text = ''
      #!${pkgs.runtimeShell}
      set -eu

      palette="$HOME/.local/state/omarchy/current/theme/colors.toml"
      log="$HOME/.local/state/omarchy/tmux-theme-hook.log"
      tmux=${pkgs.tmux}/bin/tmux
      awk=${pkgs.gawk}/bin/awk
      export TMUX_TMPDIR="''${XDG_RUNTIME_DIR:-/run/user/$UID}"

      exec >>"$log" 2>&1
      printf '%(%FT%T%z)T invoked theme=%q palette=%q tmux=%q socket_dir=%q\n' \
        -1 "''${1:-}" "$palette" "$tmux" "$TMUX_TMPDIR"

      color() {
        local name="$1"
        local value

        value=$($awk -F ' = ' -v name="$name" '$1 == name { gsub(/"/, "", $2); print $2; exit }' "$palette")
        [[ $value =~ ^#[[:xdigit:]]{6}$ ]] || exit 1
        printf '%s' "$value"
      }

      if [[ ! -r $palette ]]; then
        printf 'result=skipped reason=palette-unreadable\n'
        exit 0
      fi
      if ! server_pid=$($tmux display-message -p '#{pid}' 2>/dev/null); then
        printf 'result=skipped reason=no-tmux-server\n'
        exit 0
      fi

      background=$(color background)
      foreground=$(color foreground)
      printf 'server_pid=%s background=%s foreground=%s\n' \
        "$server_pid" "$background" "$foreground"
      $tmux set-option -g status-style "bg=$background,fg=$foreground"
      $tmux set-option -gu window-style
      $tmux set-option -gu window-active-style
      $tmux set-option -gu pane-border-style
      $tmux set-option -gu pane-active-border-style

      while IFS= read -r client; do
        [[ -n $client ]] && $tmux refresh-client -t "$client" 2>/dev/null || true
      done < <($tmux list-clients -F '#{client_name}' 2>/dev/null)

      printf 'result=updated status-style=%q window-style=%q window-active-style=%q\n' \
        "$($tmux show-options -gv status-style)" \
        "$($tmux show-options -gv window-style)" \
        "$($tmux show-options -gv window-active-style)"
    '';
  };
}
