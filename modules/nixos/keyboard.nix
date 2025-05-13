{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qmk
    vial
    via
    chromium
  ];
  services.udev.packages = with pkgs; [ vial via ];
}
