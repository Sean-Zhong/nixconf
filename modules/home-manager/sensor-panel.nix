{ config, pkgs, ... }:

let
  turzx-src = pkgs.fetchFromGitHub {
    owner = "mathoudebine";
    repo = "turing-smart-screen-python";
    rev = "main";
    hash = "sha256-vb0cqVDpTIbFe3r1nZYlmKAD+DQoOTvE1tL84xlBNII=";
  };

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    psutil
    pyserial
    pillow
    pyusb
    pyyaml
    babel
    requests
    pycryptodome
    numpy
    ping3
    uptime
    pystray
    gputil
  ]);

patchTurzx = pkgs.writeText "patch-turzx.py" ''
import os
import re

base_dir = os.path.expanduser("~/.config/turzx")
main_path = os.path.join(base_dir, "main.py")
sensors_path = os.path.join(base_dir, "library", "sensors", "sensors_python.py")

# ... [Keep your existing main.py and theme.yaml patch sections] ...

# 2. Directly override AMD GPU detection with Safe Caching and Radeontop
if os.path.exists(sensors_path):
    with open(sensors_path, "r", encoding="utf-8", errors="ignore") as f:
        scontent = f.read()

    amd_patch = """
# --- Native Linux AMD GPU Safe Polling ---
import glob
import os
import time
import subprocess
import re

_gpu_cache_time = 0.0
_gpu_cache_val = 0.0

def _get_safe_amd_pct():
    global _gpu_cache_time, _gpu_cache_val
    now = time.time()

    # Return the cached value if less than 10 seconds have passed
    if (now - _gpu_cache_time) < 10.0:
        return _gpu_cache_val

    _gpu_cache_time = now

    try:
        # Use radeontop for safe, single-shot register reading
        # -d - outputs to stdout, -l 1 limits it to 1 tick
        result = subprocess.run(["radeontop", "-d", "-", "-l", "1"], capture_output=True, text=True, timeout=2)
        if result.returncode == 0:
            match = re.search(r'gpu\s+([0-9.]+)%', result.stdout)
            if match:
                _gpu_cache_val = float(match.group(1))
    except Exception:
        pass

    return _gpu_cache_val

def _get_sysfs_amd_temp():
    # ... [Keep your existing temperature sysfs code here, as reading temps is safe] ...
    for name_file in glob.glob("/sys/class/hwmon/hwmon*/name"):
        try:
            with open(name_file, "r") as f:
                if "amdgpu" in f.read().lower():
                    hdir = os.path.dirname(name_file)
                    for tf in glob.glob(os.path.join(hdir, "temp*_input")):
                        with open(tf, "r") as tfile:
                            val = float(tfile.read().strip()) / 1000.0
                            if 0 < val < 120:
                                return val
        except Exception:
            pass
    return 0.0

class GpuMeta(type):
    def __getattr__(cls, name):
        return lambda *args, **kwargs: 0.0

class GpuOverride(metaclass=GpuMeta):
    @staticmethod
    def is_available():
        return True

    @staticmethod
    def get_gpu_to_use():
        return "AMD Radeon RX 9070 XT"

    @classmethod
    def percentage(cls, *args, **kwargs):
        return _get_safe_amd_pct()

    @classmethod
    def load(cls, *args, **kwargs):
        return _get_safe_amd_pct()

    @classmethod
    def temperature(cls, *args, **kwargs):
        return _get_sysfs_amd_temp()

    @classmethod
    def stats(cls, *args, **kwargs):
        pct = _get_safe_amd_pct()
        temp = _get_sysfs_amd_temp()
        return (pct, 0.0, 0.0, 0.0, temp)

Gpu = GpuOverride

try:
    import library.stats as stats_mod
    stats_mod.Gpu = GpuOverride
except Exception:
    pass
# --------------------------------------------
"""
    scontent += "\n" + amd_patch
    with open(sensors_path, "w", encoding="utf-8") as f:
        f.write(scontent)
'';

in {
  systemd.user.services.turzx-screen = {
    Unit = {
      Description = "Turzx V2 5.2 inch Smart Screen Monitor";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      WorkingDirectory = "${config.home.homeDirectory}/.config/turzx";
      Nice = 10;

      path = [ pkgs.radeontop ];

      Environment = [
        "LD_LIBRARY_PATH=${pkgs.libusb1}/lib"
        "PYTHONUNBUFFERED=1"
        "OMP_NUM_THREADS=1"
        "OPENBLAS_NUM_THREADS=1"
        "MKL_NUM_THREADS=1"
        "VECLIB_MAXIMUM_THREADS=1"
        "NUMEXPR_NUM_THREADS=1"
        "BLIS_NUM_THREADS=1"
        "GOTOFLAGS=-p1"
      ];

      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/.config/turzx"
        "${pkgs.coreutils}/bin/cp -f ${turzx-src}/main.py ${config.home.homeDirectory}/.config/turzx/main.py"
        "${pkgs.rsync}/bin/rsync -a --no-perms --chmod=u+rwX --exclude 'config.yaml' ${turzx-src}/ ${config.home.homeDirectory}/.config/turzx/"
        "${pkgs.gnused}/bin/sed -i 's/time.sleep(0.01)/time.sleep(0.5)/g; s/time.sleep(0.1)/time.sleep(0.5)/g' ${config.home.homeDirectory}/.config/turzx/main.py"
        "${pythonEnv}/bin/python ${patchTurzx}"
        "${pkgs.bash}/bin/bash -c 'if [ ! -f ${config.home.homeDirectory}/.config/turzx/config.yaml ]; then cp ${config.home.homeDirectory}/.config/turzx/config.example.yaml ${config.home.homeDirectory}/.config/turzx/config.yaml; fi'"
        "${pkgs.coreutils}/bin/sleep 10"
      ];
      ExecStart = "${pythonEnv}/bin/python ${config.home.homeDirectory}/.config/turzx/main.py";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
