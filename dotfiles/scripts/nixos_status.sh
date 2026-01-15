#!/usr/bin/env bash

FLAKE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/nixconf")"
CONFIG_NAME="$(hostname | sed -E 's/-([a-z])/\U\1/g')"
OUTPUT_FILE="/tmp/nixos-update-diff.txt"
UNIT_NAME="nixos-update-check"

if ! systemctl --user list-timers | grep -q "$UNIT_NAME.timer"; then
  systemd-run --user \
    --unit="$UNIT_NAME" \
    --on-calendar="12:00" \
    --on-startup="300" \
    --description="Daily NixOS Update Check" \
    --setenv=PATH="/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin" \
    bash -c "
  BUILD=\$(nix build '$FLAKE_DIR#nixosConfigurations.$CONFIG_NAME.config.system.build.toplevel' \
    --recreate-lock-file \
    --no-write-lock-file \
    --print-out-paths \
    --no-link) && \

    nvd diff /run/current-system \"\$BUILD\" > '$OUTPUT_FILE' && \

    { command -v notify-send >/dev/null && notify-send 'NixOS' 'Update check complete' || \
      echo 'notify-send not found, skipping notification'; }
    "
fi

if [ -f "$OUTPUT_FILE" ]; then
  report_time=$(stat -c %Y "$OUTPUT_FILE")
  system_time=$(stat -c %Y /run/current-system)
  if [ "$system_time" -gt "$report_time" ]; then
    rm "$OUTPUT_FILE"
  fi
fi

if [ -f "$OUTPUT_FILE" ]; then
  count=$(grep -cE '^(\[|\+|-)' "$OUTPUT_FILE")
  nix_tooltip=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$OUTPUT_FILE" | tr '\n' '\r')
else
  count="0"
  nix_tooltip="No update data available. Run check script."
fi

jq -nc --unbuffered --arg status "󱄅 $count" --arg tooltip "$nix_tooltip" '{"text": $status, "tooltip": $tooltip}'
