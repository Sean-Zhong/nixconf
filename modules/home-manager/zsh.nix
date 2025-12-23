{ pkgs, lib, config, osConfig, ... }:
let
  commonAliases = {
    ns="nix-shell";
    ns-bin="nix-shell ~/nixconf/modules/nixos/nix-shell/bin-runner.nix";
    ns-mvn="nix-shell ~/nixconf/modules/nixos/nix-shell/mvn-builder.nix";
    ns-python="nix-shell ~/nixconf/modules/nixos/nix-shell/python-env.nix";
  };
  hostSpecificAliases = lib.attrsets.getAttr osConfig.networking.hostName (import ./aliases.nix);
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = commonAliases // hostSpecificAliases;
    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";

    plugins = [
     {
       name = "nix-shell";
       src = pkgs.zsh-nix-shell;
     }
     {
       name = "powerlevel10k";
       src = pkgs.zsh-powerlevel10k;
       file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
     }
     {
       name = "powerlevel10k-config";
       src = ../../dotfiles/p10k-config;
       file = "p10k.zsh";
     }
     {
       name = "zsh-syntax-highlighting";
       src = pkgs.fetchFromGitHub {
         owner = "zsh-users";
         repo = "zsh-syntax-highlighting";
         rev = "0.8.0";
         sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
       };
     }
    ];

    # plugins
    zplug = {
     enable = true;
     plugins = [
       { name = "zsh-users/zsh-autosuggestions"; }
       { name = "plugins/git"; tags = [ from:oh-my-zsh ]; }
     ];
    };
  };
}
