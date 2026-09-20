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
        pkgs.callPackage ./nixos/pkgs/omarchy-shell.nix {
          src = omarchy;
          hyprland = pkgsUnstable.hyprland;
        };
    in
    {
      # Build the desktop runtime independently of a whole NixOS system.
      packages.${system}.omarchy-shell = mkOmarchyShell {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        pkgsUnstable = mkPkgsUnstable system;
      };

      # This is the interface a future private host flake will consume. It
      # captures the flake inputs so callers only import one workstation module.
      nixosModules.workstation = { pkgs, ... }:
        let
          hostSystem = pkgs.stdenv.hostPlatform.system;
          pkgsUnstable = mkPkgsUnstable hostSystem;
          omarchyShell = mkOmarchyShell { inherit pkgs pkgsUnstable; };
        in
        {
          # Stable Nixpkgs still carries the legacy DMS module. Import the
          # matching unstable module and disable the incompatible stable one.
          imports = [
            "${inputs.nixpkgs-unstable}/nixos/modules/services/display-managers/dms-greeter.nix"
            ./nixos/modules/boot.nix
            ./nixos/modules/desktop.nix
            ./nixos/modules/greeter.nix
            ./nixos/modules/localization.nix
            ./nixos/modules/networking.nix
            ./nixos/modules/nix.nix
            ./nixos/modules/omarchy.nix
            ./nixos/modules/packages.nix
            ./nixos/modules/programs.nix
            ./nixos/modules/services.nix
            ./nixos/modules/user-options.nix
            ./nixos/modules/user.nix
          ];
          disabledModules = [ "services/display-managers/dms-greeter.nix" ];

          # Keep unstable use visible in each module instead of hiding it in an
          # overlay. `omarchyShell` is built against the same Hyprland package.
          _module.args = {
            inherit omarchyShell pkgsUnstable;
          };
        };

      # The current laptop is deliberately composed using the same public
      # module interface that the future private wrapper flake will use.
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.workstation
          "${inputs.nixos-hardware}/framework/13-inch/intel-core-ultra-series3"
          ./nixos/hosts/nixos
        ];
      };
    };
}
