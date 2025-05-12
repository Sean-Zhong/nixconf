{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qmk
    vial
    via
  ];
  services.udev.packages = with pkgs; [ vial via ];
}
