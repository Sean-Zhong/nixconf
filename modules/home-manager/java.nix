{ pkgs, ... }:

{
    home.file."jdks/temurin11".source = pkgs.temurin-bin-11;
    home.file."jdks/temurin17".source = pkgs.temurin-bin-17;
    home.file."jdks/temurin21".source = pkgs.temurin-bin-21;
    home.file."jdks/temurin25".source = pkgs.temurin-bin-25;
    home.file."jdks/jetbrains".source = pkgs.jetbrains.jdk;

    home.sessionVariables = {
        JAVA_11_HOME = "$HOME/jdks/temurin11";
        JAVA_17_HOME = "$HOME/jdks/temurin17";
        JAVA_21_HOME = "$HOME/jdks/temurin21";
        JAVA_25_HOME = "$HOME/jdks/temurin25";
        JETBRAINS_CLIENT_JDK = "$HOME/jdks/jetbrains";
    };

    home.packages = with pkgs; [
        maven
        jdk17
        java-language-server
        jdt-language-server
    ];
}
