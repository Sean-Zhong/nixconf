----------------
--- MONITORS ---
----------------
-- Default fallback
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

local dell    = "desc:Dell Inc. DELL P3222QE 4LRLY83"
local samsung = "desc:Samsung Display Corp. 0x4196"
local benq    = "desc:BNQ BenQ PD3200U Y1J00144019"

-- Dell Monitor
hl.monitor({ output = dell, mode = "3840x2160@60", position = "3840x1200", scale = 1 })

-- Samsung Monitor
hl.monitor({ output = samsung, mode = "3840x2400@90", position = "0x0", scale = 1.5 })

-- BenQ Monitor (Rotated)
hl.monitor({ output = benq, mode = "3840x2160@60", position = "7680x0", scale = 1, transform = 1 })

------------------
--- WORKSPACES ---
------------------
hl.workspace_rule({ workspace = "1", monitor = dell, persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = dell, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = dell, persistent = true })
hl.workspace_rule({ workspace = "4", monitor = dell })
hl.workspace_rule({ workspace = "5", monitor = dell })
hl.workspace_rule({ workspace = "6", monitor = samsung, persistent = true, default = true })
hl.workspace_rule({ workspace = "7", monitor = benq, persistent = true, default = true })
