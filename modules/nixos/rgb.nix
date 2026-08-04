{ config, pkgs, inputs, ... }:

{
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb;
    motherboard = "amd";
    server = {
      port = 6742;
    };
  };

  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
}
