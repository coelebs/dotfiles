{
  description = "Vin's reusable NixOS workstation configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO move away from needing this
    dotfiles = {
      url = "path:..";
      flake = false;
    };

    omarchy = {
      url = "github:omacom/omarchy";
      flake = false;
    };

    # The pinentry plugin source is published from the same owner that
    # maintains this repository; the lock file pins the exact revision used
    # for builds.
    pinentry-omarchy = {
      url = "github:coelebs/pinentry-omarchy";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, omarchy, pinentry-omarchy, ... }:
    let
      system = "x86_64-linux";

      mkPkgsUnstable = system:
        import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

      mkOmarchyShell = { pkgs, pkgsUnstable }:
        pkgs.callPackage ./packages/omarchy-shell.nix {
          src = omarchy;
          hyprland = pkgsUnstable.hyprland;
        };
      mkPinentryOmarchy = { pkgs, omarchyShell ? null }:
        pkgs.callPackage ./packages/pinentry-omarchy.nix {
          inherit omarchyShell;
          src = pinentry-omarchy;
        };
      mkOpencode2 = pkgs: pkgs.callPackage ./packages/opencode2.nix { };
    in
    {
      # Standalone Home Manager for Omarchy on Arch. The NixOS workstation
      # still imports the same home module through its NixOS integration.
      homeConfigurations.vin =
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./modules/home/default.nix ];
          extraSpecialArgs = {
            primaryUser = "vin";
            dotfiles = inputs.dotfiles;
            pkgsUnstable = mkPkgsUnstable system;
            opencode2 = mkOpencode2 pkgs;
            omarchyShell = null;
            pinentryOmarchy = mkPinentryOmarchy { inherit pkgs; };
            onNixOS = false;
          };
        };

      # Build the desktop runtime independently of a whole NixOS system.
      packages.${system} =
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          omarchyShell = mkOmarchyShell {
            inherit pkgs;
            pkgsUnstable = mkPkgsUnstable system;
          };
        in
        {
          omarchy-shell = omarchyShell;
          pinentry-omarchy = mkPinentryOmarchy { inherit pkgs omarchyShell; };
          nixos-switch = pkgs.callPackage ./packages/nixos-switch.nix { };
          opencode2 = mkOpencode2 pkgs;
        };

      # The private machine flake consumes this module. It captures the flake
      # inputs so callers only import one workstation module.
      nixosModules.workstation = { pkgs, ... }:
        let
          hostSystem = pkgs.stdenv.hostPlatform.system;
          pkgsUnstable = mkPkgsUnstable hostSystem;
          omarchyShell = mkOmarchyShell { inherit pkgs pkgsUnstable; };
          pinentryOmarchy = mkPinentryOmarchy { inherit pkgs omarchyShell; };
          opencode2 = mkOpencode2 pkgs;
        in
        {
          # Stable Nixpkgs still carries the legacy DMS module. Import the
          # matching unstable module and disable the incompatible stable one.
          imports = [
            # Module imports must be fixed before NixOS evaluates options, so
            # Home Manager is imported here rather than from a local module.
            inputs.home-manager.nixosModules.home-manager
            "${inputs.nixpkgs-unstable}/nixos/modules/services/display-managers/dms-greeter.nix"
            ./modules/nixos/workstation.nix
          ];
          disabledModules = [ "services/display-managers/dms-greeter.nix" ];

          # Keep unstable use visible in each module instead of hiding it in an
          # overlay. `omarchyShell` is built against the same Hyprland package.
          _module.args = {
            inherit omarchyShell opencode2 pinentryOmarchy pkgsUnstable;
            dotfiles = inputs.dotfiles;
          };
        };

      # Opt in per host: private checkout locations are configuration, never
      # part of the public command or widget package.
      nixosModules."nixos-switch" = import ./modules/nixos/nixos-switch.nix;

      # Host-specific hardware belongs in the host's module list, not in the
      # reusable workstation module.
      nixosModules."framework-13" =
        import "${inputs.nixos-hardware}/framework/13-inch/intel-core-ultra-series3";
    };
}
