{ config, pkgs, ... }:

let
  turzx-src = pkgs.fetchFromGitHub {
    owner = "mathoudebine";
    repo = "turing-smart-screen-python";
    rev = "main";
    hash = "sha256-vb0cqVDpTIbFe3r1nZYlmKAD+DQoOTvE1tL84xlBNII=";
  };

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    psutil pyserial pillow pyusb pyyaml babel
    requests pycryptodome numpy ping3 uptime pystray gputil
  ]);

  patchTurzx = pkgs.writeText "patch-turzx.py" ''
import os
import re

base_dir = os.path.expanduser("~/.config/turzx")
main_path = os.path.join(base_dir, "main.py")
sensors_path = os.path.join(base_dir, "library", "sensors", "sensors_python.py")

# 1. Patch main.py for PNG performance and threading lock
if os.path.exists(main_path):
    with open(main_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    patch_main = """
# --- Performance Patch ---
import PIL.Image
import threading

_orig_save = PIL.Image.Image.save
def _fast_save(self, fp, format=None, **params):
    if format == 'PNG' or str(format).upper() == 'PNG':
        params['compress_level'] = 1
    return _orig_save(self, fp, format, **params)
PIL.Image.Image.save = _fast_save

_display_lock = threading.Lock()
try:
    import library.lcd_comm_turing_usb as usb_comm
    _orig_disp = usb_comm.LcdCommTuringUSB.DisplayPILImage
    def _locked_disp(self, *args, **kwargs):
        with _display_lock:
            return _orig_disp(self, *args, **kwargs)
    usb_comm.LcdCommTuringUSB.DisplayPILImage = _locked_disp
except Exception:
    pass
# -------------------------
"""
    content = content.replace("import sys", "import sys\n" + patch_main, 1)
    with open(main_path, "w", encoding="utf-8") as f:
        f.write(content)

# 2. Native Linux AMD GPU Power-Proxy (Dynamic Max Polling)
if os.path.exists(sensors_path):
    with open(sensors_path, "r", encoding="utf-8", errors="ignore") as f:
        scontent = f.read()

    amd_patch = """
# --- Native Linux AMD GPU Power-Proxy ---
import glob
import os

def _get_safe_amd_pct():
    max_pct = 0.0
    for name_file in glob.glob("/sys/class/hwmon/hwmon*/name"):
        try:
            with open(name_file, "r") as f:
                if "amdgpu" in f.read().lower():
                    hdir = os.path.dirname(name_file)

                    cur_power = 0.0
                    power_file = os.path.join(hdir, "power1_input")
                    if not os.path.exists(power_file):
                        power_file = os.path.join(hdir, "power1_average")

                    if os.path.exists(power_file):
                        with open(power_file, "r") as pf:
                            cur_power = float(pf.read().strip())

                    cap_power = 250000000.0
                    cap_file = os.path.join(hdir, "power1_cap")
                    if os.path.exists(cap_file):
                        with open(cap_file, "r") as cf:
                            cap_power = float(cf.read().strip())

                    if cur_power > 0 and cap_power > 0:
                        pct = (cur_power / cap_power) * 100.0
                        if pct > max_pct:
                            max_pct = pct
        except Exception:
            pass
    return min(max(max_pct, 0.0), 100.0)

def _get_sysfs_amd_temp():
    max_temp = 0.0
    for name_file in glob.glob("/sys/class/hwmon/hwmon*/name"):
        try:
            with open(name_file, "r") as f:
                if "amdgpu" in f.read().lower():
                    hdir = os.path.dirname(name_file)
                    for tf in glob.glob(os.path.join(hdir, "temp*_input")):
                        try:
                            with open(tf, "r") as tfile:
                                val = float(tfile.read().strip()) / 1000.0
                                if 0 < val < 120 and val > max_temp:
                                    max_temp = val
                        except Exception:
                            pass
        except Exception:
            pass
    return max_temp

class GpuMeta(type):
    def __getattr__(cls, name):
        return lambda *args, **kwargs: 0.0

class GpuOverride(metaclass=GpuMeta):
    @staticmethod
    def is_available():
        return True

    @staticmethod
    def get_gpu_to_use():
        return "AMD Radeon GPU"

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

# 3. Enforce 2.0s minimum intervals on theme YAMLs
theme_dir = os.path.join(base_dir, "res", "themes")
if os.path.exists(theme_dir):
    for root, _, files in os.walk(theme_dir):
        if "theme.yaml" in files:
            tpath = os.path.join(root, "theme.yaml")
            with open(tpath, "r", encoding="utf-8", errors="ignore") as f:
                tcontent = f.read()
            def enforce_min(match):
                try:
                    val = float(match.group(1))
                    return f"INTERVAL: {max(2.0, val)}"
                except ValueError:
                    return match.group(0)
            patched = re.sub(r"INTERVAL:\s*([0-9]*\.?[0-9]+)", enforce_min, tcontent)
            with open(tpath, "w", encoding="utf-8") as f:
                f.write(patched)
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
      ];

      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/sleep 10 && exec ${pythonEnv}/bin/python ${config.home.homeDirectory}/.config/turzx/main.py'";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
