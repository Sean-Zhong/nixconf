{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, home-manager, nix-index-database, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.jdoe = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          nix-index-database.hmModules.nix-index
          # optional to also wrap and install comma
          # { programs.nix-index-database.comma.enable = true; }
        ];
      };
    };

}