local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.config/hyprmodules/?.lua"

require("monitors")
require("windowrules")

-------------------
--- MY PROGRAMS ---
-------------------
local terminal    = "wezterm"
local fileManager = "nautilus"
local menu        = "wofi --show drun"
local browser     = "zen-beta"
local ide         = "idea-ultimate"

-----------------
--- AUTOSTART ---
-----------------
hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- waybar")
    hl.exec_cmd("uwsm app -- hyprpaper")
    hl.exec_cmd("uwsm app -- nm-applet")
    hl.exec_cmd("uwsm app -- hypridle")
    hl.exec_cmd("ibus-daemon -rxRd --panel disable")
    hl.exec_cmd("gnome-keyring-daemon --start --components=ssh")
    hl.exec_cmd([[bash -c 'sleep 1; export SSH_AUTH_SOCK=/run/user/$(id -u)/ssh-agent; SSH_ASKPASS=$HOME/.local/bin/my-ssh-askpass SSH_ASKPASS_REQUIRE=force ssh-add ~/.ssh/id_ed25519']])
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Grey-Dark'")
end)

-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "16")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GTK_THEME", "Orchis-Grey-Dark")
hl.env("MOZ_ENABLE_WAYLAND", "1")

---------------------
--- LOOK AND FEEL ---
---------------------
hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 3,
        border_size = 2,
        col = {
            active_border = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.2,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },

    input = {
        kb_layout = "se",
        kb_variant = "us",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    }
})

------------------
--- ANIMATIONS ---
------------------
hl.curve("easeOutQuint", { type = "bezier", points = {{0.23, 1}, {0.32, 1}} })
hl.curve("easeInOutCubic", { type = "bezier", points = {{0.65, 0.05}, {0.36, 1}} })
hl.curve("linear", { type = "bezier", points = {{0, 0}, {1, 1}} })
hl.curve("almostLinear", { type = "bezier", points = {{0.5, 0.5}, {0.75, 1.0}} })
hl.curve("quick", { type = "bezier", points = {{0.15, 0}, {0.1, 1}} })

-- Animations now use structured tables
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

---------------
--- DEVICES ---
---------------
hl.device({
    name = "logitech-pro-x-1",
    sensitivity = 0,
})

hl.device({
    name = "logitech-pro-x-2",
    sensitivity = -0.5,
})

-------------------
--- KEYBINDINGS ---
-------------------
require("keybinds")

----------------------------------
--- WINDOWS AND LAYER RULES    ---
----------------------------------
hl.layer_rule({
    match = { namespace = "logout_dialog" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0
})

