hl.on("hyprland.start", function()
    hl.exec_cmd("zen-beta")
    hl.exec_cmd("discord")
end)

hl.window_rule({
    match = { class = "^(zen%-beta)$" },
    workspace = "1"
})

hl.window_rule({
    match = { class = "^discord$" },
    workspace = "6"
})
