{ config, pkgs, inputs, outputs, ... }:
{
  home.packages = with pkgs; [
    libsecret
  ];

  home.file.".local/bin/my-ssh-askpass" = {
  executable = true;
  text = ''
      #!/bin/sh
      # Try to find the password in the keyring
      PASS=$(${pkgs.libsecret}/bin/secret-tool lookup intent ssh-key)

      if [ -n "$PASS" ]; then
        echo "$PASS"
      else
        exit 1
      fi
    '';
  };

}
