{ config, pkgs, ... }:

let
  vpnConfigName = "scila";
  vpnUser = "sean.zhong";
  vpnScript = pkgs.writeShellScriptBin "vpn-toggle" ''
    OPENVPN3="${pkgs.openvpn3}/bin/openvpn3"
    WOFI="${pkgs.wofi}/bin/wofi"
    EXPECT="${pkgs.expect}/bin/expect"
    NOTIFY="${pkgs.libnotify}/bin/notify-send"
    GREP="${pkgs.gnugrep}/bin/grep"

    # Check session status
    SESSION_PATH=$($OPENVPN3 sessions-list | $GREP -oP 'Path: \K.*' | head -n 1)

    disconnect_vpn() {
        if [ -n "$SESSION_PATH" ]; then
            $NOTIFY "VPN" "Disconnecting..."
            $OPENVPN3 session-manage --session-path "$SESSION_PATH" --disconnect
        fi
    }

    connect_vpn() {
        # 1. Prompt for Password
        PASSWORD=$($WOFI --dmenu --password --prompt "VPN Password" --lines 0 --cache-file /dev/null)
        [ -z "$PASSWORD" ] && exit 0 

        # 2. Prompt for 2FA
        TWOFA=$($WOFI --dmenu --password --prompt "2FA Code" --lines 0 --cache-file /dev/null)
        [ -z "$TWOFA" ] && exit 0 

        # 3. Combine Creds
        FULL_PASSWORD="''${PASSWORD}''${TWOFA}"
        
        $NOTIFY "VPN" "Connecting to ${vpnConfigName}..."

        # 4. Automate entry
        $EXPECT <<EOD
        spawn $OPENVPN3 session-start --config "${vpnConfigName}"
        expect "Auth User name:"
        send "${vpnUser}\r"
        expect "Auth Password:"
        send "$FULL_PASSWORD\r"
        expect eof
    EOD
    }

    # --- MAIN LOGIC ---

    if [ "$1" == "toggle" ]; then
        if [ -n "$SESSION_PATH" ]; then
            disconnect_vpn
        else
            connect_vpn
        fi
        exit 0
    fi

    # JSON Output for Waybar
    if [ -n "$SESSION_PATH" ]; then
        echo '{"text": "VPN Connected", "class": "connected", "alt": "connected", "tooltip": "Click to Disconnect"}'
    else
        echo '{"text": "VPN Disconnected", "class": "disconnected", "alt": "disconnected", "tooltip": "Click to Connect"}'
    fi
  '';
in
{
  home.packages = [ vpnScript ];
}
