{ pkgs, pkgsUnstable, system, inputs, ... }:
{
    home.packages = with pkgs; [
        jetbrains.idea
        sshfs
        vscode-fhs
        openssh
        wezterm
        devpod
        jetbrains.gateway
        go
        ripgrep
        binutils
        cookiecutter
        inputs.dagger.packages.${system}.dagger
        jetbrains.pycharm-oss
        tree
        openvpn3
        jq
        kitty
        nvd
    ];
}
