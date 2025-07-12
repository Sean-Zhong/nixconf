{ config, pkgs, inputs, ... }:

{
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins; 
    motherboard = "amd";
    server = {
            port = 6742;
        };
    };

  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
}
