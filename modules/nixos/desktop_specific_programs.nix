{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    discord
    lutris
    runelite
    piper
    libratbag
    steam-run
    bolt-launcher
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  services.ratbagd.enable = true;
}
