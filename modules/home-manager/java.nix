{ config, pkgs, ... }:

{
    home.file."jdks/temurin11".source = pkgs.temurin-bin-11;
    home.file."jdks/temurin17".source = pkgs.temurin-bin-17;
    home.file."jdks/temurin21".source = pkgs.temurin-bin;
    home.file."jdks/graalvm-ce".source = pkgs.graalvm-ce;
    home.file."jdks/jetbrains".source = pkgs.jetbrains.jdk;

    home.sessionVariables = {
        JAVA_11_HOME = "$HOME/jdks/temurin11";
        JAVA_17_HOME = "$HOME/jdks/temurin17";
        JAVA_21_HOME = "$HOME/jdks/temurin21";
        GRAAL_HOME = "$HOME/jdks/graalvm-ce";
        JETBRAINS_CLIENT_JDK = "$HOME/jdks/jetbrains";
    };

    home.packages = with pkgs; [
        maven
        gradle
        jdk17
        graalvm-ce
        java-language-server
        jdt-language-server
    ];
}