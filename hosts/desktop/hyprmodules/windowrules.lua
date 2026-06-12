hl.on("hyprland.start", function()
    hl.exec_cmd("zen-beta")
    hl.exec_cmd("vesktop")
end)

hl.window_rule({
    match = { class = "^(zen-beta)$" },
    workspace = "1"
})

hl.window_rule({
    match = { class = "^(vesktop)$" },
    workspace = "6"
})
