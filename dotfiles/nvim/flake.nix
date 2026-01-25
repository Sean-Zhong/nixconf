{
  description = "Portable Neovim Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        sharedPlugins = import ./nix/plugins.nix { inherit pkgs; };
        sharedPackages = import ./nix/dependencies.nix { inherit pkgs; };

        my-config = pkgs.vimUtils.buildVimPlugin {
          name = "my-config";
          src = ./.;
          doCheck = false;
          postInstall = ''
            mkdir -p $out/after/plugin
            mv $out/init.lua $out/after/plugin/launch.lua
          '';
        };

        nvim-base = pkgs.neovim.override {
          extraLuaPackages = ps: [ ps.magick ];
          configure = {
            customRC = ''
              set termguicolors
            '';
            packages.myVimPackage = {
              start = sharedPlugins ++ [ my-config ]; 
            };
          };
        };

        nvim-final = pkgs.symlinkJoin {
          name = "nvim";
          paths = [ nvim-base ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/nvim \
              --prefix PATH : ${pkgs.lib.makeBinPath sharedPackages}
          '';
        };
      in
      {
        packages.default = nvim-final;

        apps.default = {
          type = "app";
          program = "${nvim-final}/bin/nvim";
        };
      }
    );
}

