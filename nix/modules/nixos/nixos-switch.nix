# Optional application integration. Nix installs the CLI and widget; Omarchy
# owns the writable bar layout and adds our widget through its public command.
{ config, lib, omarchyShell, pkgs, ... }:

let
  cfg = config.programs.omarchyNixosSwitch;
  application = pkgs.callPackage ../../packages/nixos-switch.nix { };
  command = pkgs.writeTextFile {
    name = "configured-nixos-switch";
    destination = "/bin/nixos-switch";
    executable = true;
    text = ''
      #!${pkgs.dash}/bin/dash
      export NIXOS_SWITCH_MACHINE_FLAKE=${lib.escapeShellArg cfg.machineFlake}
      export NIXOS_SWITCH_DOTFILES_CHECKOUT=${lib.escapeShellArg cfg.dotfilesCheckout}
      export NIXOS_SWITCH_CONFIGURATION=${lib.escapeShellArg cfg.configuration}
      exec ${application}/bin/nixos-switch "$@"
    '';
  };
  ensureWidget = pkgs.writeShellScript "ensure-nixos-switch-widget" ''
    export PATH=${lib.makeBinPath [ omarchyShell pkgs.coreutils ]}:"$PATH"
    exec ${application}/libexec/nixos-switch/ensure-widget
  '';
in
{
  options.programs.omarchyNixosSwitch = {
    enable = lib.mkEnableOption "the NixOS switch CLI and Omarchy progress widget";
    machineFlake = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/home/vin/Projects/machine";
      description = "Absolute location of the live machine flake checkout at runtime.";
    };
    dotfilesCheckout = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/home/vin/Projects/dotfiles";
      description = "Absolute location of the live dotfiles checkout containing nix/flake.nix.";
    };
    configuration = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "NixOS configuration name after the # in --flake.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.machineFlake;
        message = "programs.omarchyNixosSwitch.machineFlake must be an absolute checkout path";
      }
      {
        assertion = lib.hasPrefix "/" cfg.dotfilesCheckout;
        message = "programs.omarchyNixosSwitch.dotfilesCheckout must be an absolute checkout path";
      }
    ];

    home-manager.users.${config.dotfiles.primaryUser} = { lib, ... }: {
      home.packages = [ command ];
      xdg.configFile."omarchy/plugins/coelebs.nixos-switch".source =
        "${application}/share/omarchy/plugins/coelebs.nixos-switch";
      xdg.configFile."omarchy/hooks/post-boot.d/coelebs-nixos-switch" = {
        source = ensureWidget;
        executable = true;
      };
      xdg.configFile."omarchy/hooks/post-update.d/coelebs-nixos-switch" = {
        source = ensureWidget;
        executable = true;
      };

      # A rebuild in a live desktop need not wait until next login. The same
      # script is also used by the hooks, so first install works headlessly.
      # The symlink must exist before we ask Omarchy to discover it.
      home.activation.ensureNixosSwitchWidget = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        ${ensureWidget}
      '';
    };
  };
}
