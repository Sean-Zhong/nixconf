{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
    name = "maven-env";
    targetPkgs = pkgs: (with pkgs; [
        maven
    ]);
    runScript = "bash";
}).env
