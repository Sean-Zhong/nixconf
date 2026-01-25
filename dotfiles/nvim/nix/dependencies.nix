{ pkgs }:

with pkgs; [
  # LSPs
  lua-language-server
  nixd
  bash-language-server
  typescript-language-server
  yaml-language-server
  typst

  # Tools
  ueberzugpp
  imagemagick
  ripgrep
  fd
]
