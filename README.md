# Nixos Configuration and Dotfiles
My personal nixos configuration and dotfiles. The Nixos and Home manager configurations are managed using a nix flake. Dotfiles for `hyprland`, `nvim` and other programs are symlinked into nixos usin home manager.

## Rebuilding config
Rebuilding the configuration can be done by running: `sudo nixos-rebuild switch --flake ~/nixconf/#{HOSTNAME}` or the: `update` shell alias. The update shell alias needs to be configured in `nixconf/moduled/home-manager/aliases.nix`:

``` nix
{
  "nixos" = {
    update = "sudo nixos-rebuild switch --flake ~/nixconf/#nixos";
  };
  "desktop" = {
    update = "sudo nixos-rebuild switch --flake ~/nixconf/#desktop";
  };
}
```

## Updating flake.lock
The versions of `nix-packages`, `home-manager` and `hyprland` are pinned using the `flake.lock` file. To update the versions run: 
```bash
nix flake update
```

## Modules
`Nixos` and `Home Manager` modules can be linked into and used in `configuration.nix` and `home.nix`

