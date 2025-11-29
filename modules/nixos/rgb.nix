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

  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  services.udev.extraRules =  builtins.readFile ../../resources/udev/60-openrgb.rules;
}
