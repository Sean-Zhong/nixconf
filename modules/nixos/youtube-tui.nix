{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.python314
    pkgs.mpv-unwrapped
  ];
}