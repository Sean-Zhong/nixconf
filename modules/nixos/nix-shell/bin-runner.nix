{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
    name = "bash-env";
    targetPkgs = pkgs: (with pkgs; [
        zlib
    ]);
    runScript = "bash";
}).env
