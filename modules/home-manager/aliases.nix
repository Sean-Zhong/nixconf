{
  "nixos" = {
    update = "sudo nixos-rebuild switch --flake ~/nixconf/#nixos";
  };
  "desktop" = {
    update = "sudo nixos-rebuild switch --flake ~/nixconf/#desktop";
  };
}
