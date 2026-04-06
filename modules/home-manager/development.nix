{ pkgs, pkgsUnstable, system, inputs, ... }:
{
    home.packages = with pkgs; [
        pkgsUnstable.jetbrains.idea
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
        git-crypt
        ffmpegthumbnailer # Video thumbnails
        unzip             # Archive previews
        jq                # JSON previews
        poppler           # PDF previews
        fd                # File searching
        ripgrep           # File content searching
        fzf               # Fuzzy finding
        zoxide            # Historical directory navigation
    ];

    home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
    };

    programs.yazi = {
        enable = true;
        enableBashIntegration = true; # default is true
        enableZshIntegration = true;  # default is true
        enableFishIntegration = true; # default is true
    };

}
