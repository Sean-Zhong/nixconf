{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    runelite
    piper
    libratbag
    steam-run
    bolt-launcher
    wootility
    vesktop
    prismlauncher
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.gamescope = {
    enable = true;
    #capSysNice = true;
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
  networking.firewall.trustedInterfaces = [ "waydroid0" ];


  services.ratbagd.enable = true;
}
