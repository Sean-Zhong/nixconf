{
  description = "Nixos config flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    pkgsUnstable = import nixpkgs-unstable {
        config = {
          allowUnfree = true;
        };
      };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/nixos/configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/desktop/configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };

  };
}
