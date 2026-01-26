# Sean Zhong Neovim Flake

Run the flake on any computer with nix installed:

`nix run github:sean-zhong/nixconf?dir=dotfiles/nvim`

To install the flake into nix profile:

`nix profile install "github:sean-zhong/nixconf?dir=dotfiles/nvim"`

The flake can also output a docker image. It is currently uploaded to docker hub.

`szh11/nvim-flake:latest`
