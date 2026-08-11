hl.on("hyprland.start", function()
    hl.exec_cmd("[workspace 1 silent] zen-beta")
    hl.exec_cmd("idea")
end)

hl.window_rule({
    match = { class = "^(zen-beta)$" },
    workspace = "1"
})

hl.window_rule({
    match = { class = "^(jetbrains-idea)$" },
    workspace = "2"
})

hl.window_rule({
    match = { class = "^chrome-auth.*" },
    float = true,
    size = "600 700",
    center = true
})
