{ config, inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets."browser_json" = {
    sopsFile = ../../secrets/ytmusic-tui-browser.yaml;
    path = "${config.home.homeDirectory}/.config/ytmusic-tui/browser.json";
  };
}
