{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.python314
    pkgs.python312Packages.ytmusicapi
    pkgs.ytermusic
  ];
}