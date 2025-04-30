{ pkgs, ... }:

{
    home.pointerCursor =
        let
        getFrom = url: hash: name: {
            gtk.enable = true;
            x11.enable = true;
            name = name;
            size = 16;
            package = pkgs.runCommand "moveUp" { } ''
            mkdir -p $out/share/icons
            ln -s ${
                pkgs.fetchzip {
                url = url;
                hash = hash;
                }
            } $out/share/icons/${name}
            '';
        };
        in
        getFrom "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.4/Bibata-Modern-Ice.tar.xz"
        "sha256-1U/HoGO/FG/EI6kUqf9sXVL8rfLIsopQLBbDVyxIuX4="
        "Bibata-Modern-Ice";

    gtk = {
        enable = true;
        theme = {
	        package = pkgs.orchis-theme;
	        name = "Orchis-Grey-Dark";
	    };

	    iconTheme = {
	        package = pkgs.tela-icon-theme;
	        name = "Tela-blue-dark";
	    };
        
        cursorTheme = {
        name = "Bibata-Modern-Ice";
        size = 16;
        };
    };
}
