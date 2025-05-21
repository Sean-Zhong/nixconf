{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    cpulimit
  ];

  systemd.user.timers = {
    antivirus-scan = {
      Unit.Description = "timer for antivirus-scan";
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnUnitInactiveSec = "1w";
        OnCalendar = "*-*-01 10:00:00";
        Unit = "antivirus-scan.service";
      };
    };
  };
  systemd.user.services = {
    antivirus-scan = {
      Unit.Description = "service for antivirus-scan";
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "anti-virus-script" ''
            PATH=$PATH:${
              lib.makeBinPath [
                pkgs.coreutils
                pkgs.libnotify
                pkgs.cpulimit
                pkgs.clamav
              ]
            }
            ${pkgs.bash}/bin/bash "/home/sean/scripts/clamscan.sh";
          ''
        );
      };
    };
  };
}
