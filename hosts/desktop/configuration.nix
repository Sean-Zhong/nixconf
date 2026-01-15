{ config, lib, pkgs, inputs, outputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nixos/desktop_specific_programs.nix
      ../../modules/nixos/youtube-tui.nix
      ../../modules/nixos/hyprland.nix
      ../../modules/nixos/gc.nix
      ../../modules/nixos/ssh.nix
      ../../modules/nixos/keyboard.nix
      ../../modules/nixos/rgb.nix
      ../../modules/nixos/gpu.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop"; # Define your hostname.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.defaultSession = "hyprland-uwsm";

  # xdg portal
  services.dbus.enable = true;
  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      wlr.enable = true;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "se";
    variant = "us";
  };

  # RDP
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
  services.xrdp.openFirewall = true;

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.flatpak.enable = true;
  hardware.keyboard.qmk.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  #turn off mouse accel
  services.libinput = {
    enable = true;
    # disabling mouse acceleration
    mouse = {
      accelProfile = "flat";
    };

    # disabling touchpad acceleration
    touchpad = {
      accelProfile = "flat";
    };
  }; 

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sean = {
    isNormalUser = true;
    description = "Sean Zhong";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    git
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      "sean" = import ./home.nix;
    };
  };

  programs.firefox.enable = true;
  programs.openvpn3.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    keyutils
    cifs-utils
    bambu-studio
  ];

  environment.shells = with pkgs; [ zsh ];

  fonts.packages = with pkgs; [
    meslo-lgs-nf
  ];

  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };

  # Docker
  virtualisation.docker = {
    enable = true;
  };

  # Needed for default bridge network to automatically work
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.ip_forward" = 1;

  services.udev.extraRules = ''
    # Fractal Scape: Allow user access AND unbind kernel driver from Interface 3
    SUBSYSTEM=="usb", ATTRS{idVendor}=="36bc", ATTRS{idProduct}=="0001", MODE="0666"

    # Automatically unbind the 'hid-generic' driver from Interface 3 when plugged in
    SUBSYSTEM=="hid", DRIVERS=="hid-generic", ATTRS{idVendor}=="36bc", ATTRS{idProduct}=="0001", RUN+="${pkgs.bash}/bin/sh -c 'echo $kernel > /sys/bus/hid/drivers/hid-generic/unbind'"
  '';
  nix.settings.auto-optimise-store = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.stateVersion = "24.11"; # Did you read the comment?
}
