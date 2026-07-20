hl.on("hyprland.start", function()
    hl.exec_cmd("zen-beta")
    hl.exec_cmd([[sh -c "systemctl --user start xdg-desktop-portal.service && systemd-run --user uwsm app -- vesktop"]])
    hl.exec_cmd([[uwsm app -- quickshell]])
end)

hl.window_rule({
    match = { class = "^(zen-beta)$" },
    workspace = "1"
})

hl.window_rule({
    match = { class = "^(vesktop)$" },
    workspace = "6"
})
