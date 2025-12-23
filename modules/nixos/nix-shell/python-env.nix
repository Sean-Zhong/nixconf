{ pkgs ? import <nixpkgs> {}, v ? "314" }:
let
  lib-path = with pkgs; lib.makeLibraryPath [
    libffi
    openssl
    stdenv.cc.cc
    gcc
  ];
  pythonPackage = pkgs."python${v}";
in with pkgs; mkShell {
  packages = [
    pythonPackage
    openssl
    libffi
  ];
  shellHook = ''
    export "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${lib-path}"
    VENV=.venv
    if test ! -d $VENV; then
        ${pythonPackage}/bin/python -m venv $VENV
    fi
    source ./$VENV/bin/activate > /dev/null
    ${pythonPackage}/bin/python --version
  '';
}

