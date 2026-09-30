{ lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      base16-nvim
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      copilot-vim
      gitsigns-nvim
      harpoon
      lualine-nvim
      markview-nvim
      nvim-cmp
      nvim-lint
      nvim-lspconfig
      nvim-web-devicons
      oil-nvim
      plenary-nvim
      telescope-nvim
      todo-comments-nvim
      trouble-nvim
      undotree
      vim-fugitive
      vim-sleuth
      (nvim-treesitter.withPlugins (parsers: with parsers; [
        bash c cpp go json lua markdown markdown_inline nix python query regex
        rust toml vim vimdoc yaml zsh
      ]))
    ];
    # TODO: Revisit calling OpenCode from Neovim once its integration works reliably.
    extraPackages = with pkgs; [
      clang-tools
      fd
      git
      go
      gopls
      lua-language-server
      nixd
      nodejs
      pyright
      ripgrep
      shellcheck
    ];
    initLua = builtins.readFile ./neovim/init.lua;
  };

  xdg.configFile."nvim/lua/user".source = ./neovim/lua/user;

  # The previous generation linked the entire nvim directory. Move only that
  # Home Manager-owned link before linking files *inside* the new directory;
  # otherwise linkGeneration would try to write through it into the Nix store.
  home.activation.migrateLegacyNeovim = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
    target="$HOME/.config/nvim"
    if [[ -L "$target" ]]; then
      case "$(readlink "$target")" in
        /nix/store/*-home-manager-files/.config/nvim)
          backup="$target.before-home-manager"
          suffix=1
          while [[ -e "$backup" || -L "$backup" ]]; do
            backup="$target.before-home-manager.$suffix"
            suffix=$((suffix + 1))
          done
          run mv -- "$target" "$backup"
          ;;
      esac
    fi
  '';
}
