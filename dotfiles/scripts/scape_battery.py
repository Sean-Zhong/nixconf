#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.hidapi

import hid
import time
import sys
import json
import os

VID = 0x36BC
PID = 0x0001
INTERFACE = 3
CACHE_FILE = "/tmp/fractal_battery_cache"

def save_cache(level):
    try:
        with open(CACHE_FILE, "w") as f:
            f.write(str(level))
    except:
        pass

def load_cache():
    try:
        if os.path.exists(CACHE_FILE):
            # Only use cache if it's less than 2 hours old
            if time.time() - os.path.getmtime(CACHE_FILE) < 7200:
                with open(CACHE_FILE, "r") as f:
                    return int(f.read().strip())
    except:
        pass
    return None

def get_battery_live():
    target = None
    # 1. Find the device
    for d in hid.enumerate(VID, PID):
        if d['interface_number'] == INTERFACE:
            target = d
            break
            
    if not target:
        return None

    h = None
    try:
        h = hid.device()
        h.open_path(target['path'])
        h.set_nonblocking(1)

        # 2. ASK FOR STATUS
        cmd_enable = [0x02, 0x11, 0x05, 0x01] + [0x00]*28
        h.write(cmd_enable)
        
        # 3. READ RESPONSE
        # INCREASED PATIENCE: 40 attempts * 0.05s = 2.0 seconds max wait
        for _ in range(40):
            data = h.read(64)
            if data:
                if len(data) > 8 and data[0] == 0x02 and data[1] == 0x11 and data[2] == 0x05:
                    raw_level = data[5]
                    pct = int((raw_level / 255.0) * 100)
                    h.close()
                    return pct
            time.sleep(0.05)
                
        h.close()

    except Exception:
        if h:
            try: h.close()
            except: pass

    return None

# --- MAIN LOGIC ---
bat = get_battery_live()

if bat is not None:
    # Success! Save to cache
    save_cache(bat)
else:
    # Failure! Load from cache so widget doesn't disappear
    bat = load_cache()

# --- OUTPUT ---
if bat is not None:
    if bat >= 90: icon = ""
    elif bat >= 60: icon = ""
    elif bat >= 40: icon = ""
    elif bat >= 10: icon = ""
    else: icon = ""
    
    css_class = "discharging"
    if bat > 98: css_class = "full"
    elif bat < 20: css_class = "critical"
    
    print(json.dumps({
        "text": f"{icon} {bat}%",
        "tooltip": f"Fractal Scape: {bat}%",
        "percentage": bat,
        "class": css_class
    }))
else:
    # Only hide if we have NO live data AND NO cache (truly disconnected)
    print(json.dumps({"text": "", "tooltip": "Disconnected", "class": "disconnected"}))
