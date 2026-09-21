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
      set -g status-style 'bg=#333333 fg=#5eacd3'
      set -g focus-events on

      bind r source-file ~/.tmux.conf
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
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R
      set-option -g repeat-time 0

      set -g status-left-length 40
      bind-key -n C-f new-window "tmux-sessionizer"

      # Start new splits in the active pane's working directory.
      bind '"' split-window -v -c '#{pane_current_path}'
      bind % split-window -h -c '#{pane_current_path}'

      set -g extended-keys
    '';
  };
}
