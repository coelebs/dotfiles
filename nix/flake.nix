{
  description = "Vin's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/cf9d2fb3e50fa1cd5114c47505ea9177f7ff5f49";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/0a3468a402c449992505b6a9fc5b06580141b750";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omarchy = {
      url = "github:omacom/omarchy";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./nixos/configuration.nix ];
    };
  };
}
