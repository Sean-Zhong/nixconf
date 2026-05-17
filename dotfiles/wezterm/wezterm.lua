-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = 'Catppuccin Macchiato'
config.font_size = 16.0
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.enable_wayland = true
config.window_background_opacity = 0.7

-- tmux
config.leader = { key = "q", mods = "ALT", timeout_milliseconds = 2000 }
config.keys = {
    {
        mods = "LEADER",
        key = "c",
        action = wezterm.action.SpawnTab "CurrentPaneDomain",
    },
    {
        mods = "LEADER",
        key = "x",
        action = wezterm.action.CloseCurrentPane { confirm = true }
    },
    {
        mods = "LEADER",
        key = "b",
        action = wezterm.action.ActivateTabRelative(-1)
    },
    {
        mods = "LEADER",
        key = "n",
        action = wezterm.action.ActivateTabRelative(1)
    },
    {
        mods = "LEADER",
        key = "\\",
        action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }
    },
    {
        mods = "LEADER",
        key = "-",
        action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" }
    },
    {
        mods = "LEADER",
        key = "h",
        action = wezterm.action.ActivatePaneDirection "Left"
    },
    {
        mods = "LEADER",
        key = "j",
        action = wezterm.action.ActivatePaneDirection "Down"
    },
    {
        mods = "LEADER",
        key = "k",
        action = wezterm.action.ActivatePaneDirection "Up"
    },
    {
        mods = "LEADER",
        key = "l",
        action = wezterm.action.ActivatePaneDirection "Right"
    },
    {
        mods = "LEADER",
        key = "LeftArrow",
        action = wezterm.action.AdjustPaneSize { "Left", 5 }
    },
    {
        mods = "LEADER",
        key = "RightArrow",
        action = wezterm.action.AdjustPaneSize { "Right", 5 }
    },
    {
        mods = "LEADER",
        key = "DownArrow",
        action = wezterm.action.AdjustPaneSize { "Down", 5 }
    },
    {
        mods = "LEADER",
        key = "UpArrow",
        action = wezterm.action.AdjustPaneSize { "Up", 5 }
    },
    {
        mods = 'CTRL',
        key = 'V',
        action = wezterm.action.PasteFrom 'Clipboard'
    },
}

-- Update the keybindings to use 1-indexed tabs
for i = 1, 9 do
    -- leader + number to activate that tab (1-indexed)
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = wezterm.action.ActivateTab(i - 1),  -- We subtract 1 here because tabs are 0-indexed internally
    })
end

-- tab bar settings
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = false  -- Set this to false to make tab indices 1-indexed

-- Variables to store the previous CPU state to calculate usage over time
local last_cpu_total = 0
local last_cpu_idle = 0

local function get_cpu_usage()
    local f = io.open("/proc/stat", "r")
    if not f then return "N/A" end
    local line = f:read("*l")
    f:close()

    -- /proc/stat CPU line format: cpu  user nice system idle iowait irq softirq steal
    local user, nice, system, idle, iowait, irq, softirq, steal = line:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
    if not user then return "N/A" end

    local total_idle = idle + iowait
    local total_non_idle = user + nice + system + irq + softirq + steal
    local total = total_idle + total_non_idle

    local diff_total = total - last_cpu_total
    local diff_idle = total_idle - last_cpu_idle

    last_cpu_total = total
    last_cpu_idle = total_idle

    if diff_total == 0 then return "0.0%" end
    local usage = ((diff_total - diff_idle) / diff_total) * 100
    return string.format("%.1f%%", usage)
end

local function get_ram_usage()
    local f = io.open("/proc/meminfo", "r")
    if not f then return "N/A" end
    local mem_total = 0
    local mem_available = 0

    for line in f:lines() do
        if line:match("^MemTotal:") then
            mem_total = tonumber(line:match("%d+"))
        elseif line:match("^MemAvailable:") then
            mem_available = tonumber(line:match("%d+"))
        end
    end
    f:close()

    if mem_total > 0 and mem_available > 0 then
        local used = mem_total - mem_available
        -- /proc/meminfo reports in kilobytes, convert to gigabytes
        return string.format("%.1f/%.1fGB", used / 1024 / 1024, mem_total / 1024 / 1024)
    end
    return "N/A"
end

-- tmux status
wezterm.on("update-status", function(window, _)
    -- ==========================================
    -- Left Status (Leader / Wave Icon)
    -- ==========================================
    local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)
    local wave_bg = "#b7bdf8"
    local wave_fg = "#181825"

    local first_tab_bg = "#1e2030"
    local tabs = window:mux_window():tabs_with_info()

    if tabs[1] and tabs[1].is_active then
        first_tab_bg = "#c6a0f6"
    end

    if window:leader_is_active() then
        window:set_left_status(wezterm.format {
            { Background = { Color = wave_bg } },
            { Foreground = { Color = wave_fg } },
            { Text = " " .. utf8.char(0x1f30a) .. " " },

            { Background = { Color = first_tab_bg } },
            { Foreground = { Color = wave_bg } },
            { Text = SOLID_RIGHT_ARROW }
        })
    else
        -- Clear the status when leader is not active
        window:set_left_status("")
    end

    -- ==========================================
    -- Right Status (Pointy System Stats)
    -- ==========================================
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    local cpu = get_cpu_usage()
    local ram = get_ram_usage()

    -- Catppuccin Macchiato Colors
    local color_cpu = "#eed49f"
    local color_ram = "#8aadf4"
    local color_text = "#181825"

    window:set_right_status(wezterm.format {
        -- 1. Transition from empty tab bar to CPU color
        'ResetAttributes', 
        { Foreground = { Color = color_cpu } },
        { Text = SOLID_LEFT_ARROW },

        -- 2. CPU Section
        { Background = { Color = color_cpu } },
        { Foreground = { Color = color_text } },
        { Text = "  " .. cpu .. " " },

        -- 3. Transition from CPU color to RAM color
        { Background = { Color = color_cpu } },
        { Foreground = { Color = color_ram } },
        { Text = SOLID_LEFT_ARROW },

        -- 4. RAM Section
        { Background = { Color = color_ram } },
        { Foreground = { Color = color_text } },
        { Text = " 󰍛 " .. ram .. " " },
    })
end)

config.mux_enable_ssh_agent = false

-- and finally, return the configuration to wezterm
return config
