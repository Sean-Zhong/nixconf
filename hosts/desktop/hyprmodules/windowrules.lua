hl.on("hyprland.start", function()
    hl.exec_cmd("zen-beta")
    hl.exec_cmd([[sh -c "systemctl --user start xdg-desktop-portal.service && systemd-run --user uwsm app -- vesktop"]])
end)

hl.window_rule({
    match = { class = "^(zen-beta)$" },
    workspace = "1"
})

hl.window_rule({
    match = { class = "^(vesktop)$" },
    workspace = "6"
})

hl.window_rule({
    match = { class = "vpn-auth" },
    float = true,
    size = "550 320",
    center = true,
    stayfocused = true,
    animation = "popin 80%"
})
