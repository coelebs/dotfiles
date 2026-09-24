{
  # This flake is the public entry point for reusable workstation configuration.
  # It owns dependency pins, exports a workstation module, and composes the
  # current machine from that module and its machine-specific host definition.
  description = "Vin's reusable NixOS workstation configuration";

  inputs = {
    # The system always evaluates from a stable NixOS release. The lock file,
    # rather than this branch name, pins the exact revision used for builds.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # This is intentionally a separate, explicit package set. Modules receive
    # it as `pkgsUnstable` and may use it only for documented exceptions.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager shares the stable package set with NixOS. It owns files and
    # packages in the primary user's home directory, not system services.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The flake lives in nix/, while the deployable dotfile trees live at the
    # repository root. Keep that source explicit so pure flake evaluation can
    # include them without copying or rewriting the established Stow layout.
    dotfiles = {
      url = "path:..";
      flake = false;
    };

    # Omarchy is source data, not a Nix flake. The local package definition
    # below builds the NixOS-compatible runtime from this locked source.
    omarchy = {
      url = "github:omacom/omarchy";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, omarchy, ... }:
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
      mkPinentryOmarchy = { pkgs, omarchyShell }:
        pkgs.callPackage ./packages/pinentry-omarchy.nix { inherit omarchyShell; };
    in
    {
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
        };

      # This is the interface a future private host flake will consume. It
      # captures the flake inputs so callers only import one workstation module.
      nixosModules.workstation = { pkgs, ... }:
        let
          hostSystem = pkgs.stdenv.hostPlatform.system;
          pkgsUnstable = mkPkgsUnstable hostSystem;
          omarchyShell = mkOmarchyShell { inherit pkgs pkgsUnstable; };
          pinentryOmarchy = mkPinentryOmarchy { inherit pkgs omarchyShell; };
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
            inherit omarchyShell pinentryOmarchy pkgsUnstable;
            dotfiles = inputs.dotfiles;
          };
        };

      # The current laptop is deliberately composed using the same public
      # module interface that the future private wrapper flake will use.
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.workstation
          "${inputs.nixos-hardware}/framework/13-inch/intel-core-ultra-series3"
          ./hosts/nixos
        ];
      };
    };
}
