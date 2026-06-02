-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------
hl.env("WLR_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")

----------------
--- MONITORS ---
----------------
-- Default fallback
hl.monitor({ 
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto"
})

-- Main LG Monitor
hl.monitor({
    output = "desc:LG Electronics LG ULTRAGEAR+ 503NTSU1W910",
    mode = "2560x1440@480.17",
    position = "1080x1080",
    scale = 1
})

-- Dell Monitor (Rotated)
hl.monitor({
    output = "desc:Dell Inc. DELL P2314H J8J31485BEPL",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
    transform = 3
})

-- Secondary LG Monitor
hl.monitor({
    output = "desc:LG Electronics 24GM79G 0x0006A1BE",
    mode = "1920x1080@144",
    position = "1080x0",
    scale = 1
})

------------------
--- WORKSPACES ---
------------------
local lgMain = "desc:LG Electronics LG ULTRAGEAR+ 503NTSU1W910"
local dell   = "desc:Dell Inc. DELL P2314H J8J31485BEPL"
local lgSec  = "desc:LG Electronics 24GM79G 0x0006A1BE"

hl.workspace_rule({ workspace = "1", persistent = true, default = true, monitor = lgMain })
hl.workspace_rule({ workspace = "2", persistent = true, monitor = lgMain })
hl.workspace_rule({ workspace = "3", persistent = true, monitor = lgMain })
hl.workspace_rule({ workspace = "4", monitor = lgMain })
hl.workspace_rule({ workspace = "5", monitor = lgMain })
hl.workspace_rule({ workspace = "6", persistent = true, default = true, monitor = dell })
hl.workspace_rule({ workspace = "7", persistent = true, default = true, monitor = lgSec })
