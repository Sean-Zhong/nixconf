{ config, inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

  sops.secrets."browser_json" = {
    sopsFile = ../../secrets/ytmusic-tui-browser.yaml;
    path = "${config.home.homeDirectory}/.config/ytmusic-tui/browser.json";
  };
}
