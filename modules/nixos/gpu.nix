{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Load AMD driver for Xorg and Wayland
  services.xserver.videoDrivers = ["amdgpu"];
  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
  ];

  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
