import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: nixPill
    color: "transparent"
    implicitWidth: 42
    implicitHeight: 32

    property int currentBrightness: 100

    property bool isWifiOn: wifiStatusText.text.indexOf("ON") !== -1
    property bool isBtOn: btStatusText.text.indexOf("ON") !== -1

    Text {
        anchors.centerIn: parent
        text: "" 
        color: "#74c7ec"
        font.pixelSize: 24
        font.family: "JetBrainsMono Nerd Font"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: { nixMenuPopup.visible = !nixMenuPopup.visible }
    }

    Process { id: setBrightnessProc }
    Process { id: wifiToggleProc }
    Process { id: wifiAppProc }
    Process { id: btToggleProc }
    Process { id: btAppProc }

    function runCmd(proc, cmd) {
        proc.running = false
        proc.command = ["sh", "-c", cmd]
        proc.running = true
    }

    // ==========================================
    // POPUP MENU (SETTINGS & CONTROLS)
    // ==========================================
    PopupWindow {
        id: nixMenuPopup
        anchor.item: nixPill
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: false
        grabFocus: true
        color: "transparent"
        implicitWidth: 300
        implicitHeight: 390

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: "#313244"
            border.width: 1
            radius: 12

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                // ------------------------------------------
                // HEADER
                // ------------------------------------------
                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: ""
                        color: "#74c7ec"
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: "Quick Settings"
                        color: "#cdd6f4"
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#313244" }

                // ------------------------------------------
                // 1. SCREEN BRIGHTNESS SLIDER
                // ------------------------------------------
                Column {
                    width: parent.width
                    spacing: 8

                    Row {
                        width: parent.width
                        Text {
                            text: "󰃠  Brightness"
                            color: "#f9e2af"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.right: parent.right
                            text: nixPill.currentBrightness + "%"
                            color: "#cdd6f4"
                            font.pixelSize: 13
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Process {
                        running: true
                        command: ["sh", "-c", "while true; do brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'; sleep 1; done"]
                        stdout: SplitParser { 
                            onRead: (data) => {
                                var val = parseInt(data.trim())
                                if (!isNaN(val)) {
                                    nixPill.currentBrightness = val
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            text: "󰃞"
                            color: "#f9e2af"
                            font.pixelSize: 15
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: parent.width - 54
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                id: sliderTrack
                                anchors.centerIn: parent
                                width: parent.width
                                height: 8
                                radius: 4
                                color: "#2a2b3d"

                                Rectangle {
                                    width: (nixPill.currentBrightness / 100) * parent.width
                                    height: parent.height
                                    radius: 4
                                    color: "#f9e2af"
                                }
                            }

                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: sliderMouse.containsMouse || sliderMouse.pressed ? "#ffffff" : "#f9e2af"
                                anchors.verticalCenter: parent.verticalCenter
                                x: Math.max(0, Math.min(parent.width - width, ((nixPill.currentBrightness / 100) * parent.width) - (width / 2)))
                                border.color: "#1e1e2e"
                                border.width: 2

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰃠"
                                    color: "#1e1e2e"
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }

                            MouseArea {
                                id: sliderMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                function updateBrightness(mouseX) {
                                    var clampedX = Math.max(0, Math.min(width, mouseX))
                                    var pct = Math.round((clampedX / width) * 100)
                                    pct = Math.max(1, Math.min(100, pct))

                                    nixPill.currentBrightness = pct
                                    nixPill.runCmd(setBrightnessProc, "brightnessctl set " + pct + "%")
                                }

                                onPressed: { updateBrightness(mouse.x) }
                                onPositionChanged: {
                                    if (pressed) {
                                        updateBrightness(mouse.x)
                                    }
                                }
                            }
                        }

                        Text {
                            text: "󰃠"
                            color: "#f9e2af"
                            font.pixelSize: 17
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#313244" }

                // ------------------------------------------
                // 2. WI-FI / NETWORKING
                // ------------------------------------------
                Column {
                    width: parent.width
                    spacing: 6

                    Row {
                        width: parent.width
                        Text {
                            text: "󰤨  Wi-Fi"
                            color: "#a6e3a1"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            id: wifiStatusText
                            anchors.right: parent.right
                            text: "OFF"
                            color: nixPill.isWifiOn ? "#a6e3a1" : "#f38ba8"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Process {
                        id: wifiCheckProc
                        running: true
                        command: ["sh", "-c", "while true; do if rfkill list wlan 2>/dev/null | grep -q 'Soft blocked: yes'; then echo 'OFF'; else SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2); if [ -n \"$SSID\" ]; then echo \"ON ($SSID)\"; else echo \"ON (Disconnected)\"; fi; fi; sleep 2; done"]
                        stdout: SplitParser { onRead: (data) => { wifiStatusText.text = data.trim() } }
                    }

                    Row {
                        width: parent.width
                        spacing: 8

                        Rectangle {
                            width: (parent.width - 8) / 2; height: 32; radius: 6
                            color: {
                                if (nixPill.isWifiOn) {
                                    return wifiToggleMouse.containsMouse ? "#8ce187" : "#a6e3a1"
                                }
                                return wifiToggleMouse.containsMouse ? "#313244" : "#2a2b3d"
                            }
                            Row {
                                anchors.centerIn: parent; spacing: 6
                                Text { 
                                    text: "󰤨" 
                                    color: nixPill.isWifiOn ? "#1e1e2e" : "#a6e3a1"
                                    font.pixelSize: 13
                                    font.family: "JetBrainsMono Nerd Font" 
                                }
                                Text { 
                                    text: "Toggle" 
                                    color: nixPill.isWifiOn ? "#1e1e2e" : "#cdd6f4"
                                    font.pixelSize: 12
                                    font.bold: nixPill.isWifiOn
                                    font.family: "JetBrainsMono Nerd Font" 
                                }
                            }
                            MouseArea {
                                id: wifiToggleMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    nixPill.runCmd(wifiToggleProc, "rfkill toggle wlan || nmcli radio wifi toggle")
                                    wifiCheckProc.running = false
                                    wifiCheckProc.running = true
                                }
                            }
                        }

                        Rectangle {
                            width: (parent.width - 8) / 2; height: 32; radius: 6
                            color: wifiAppMouse.containsMouse ? "#313244" : "#2a2b3d"
                            Row {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "󰒓"; color: "#89b4fa"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: "Settings"; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            }
                            MouseArea {
                                id: wifiAppMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    nixPill.runCmd(wifiAppProc, "nm-connection-editor || kitty -e nmtui")
                                    nixMenuPopup.visible = false
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#313244" }

                // ------------------------------------------
                // 3. BLUETOOTH
                // ------------------------------------------
                Column {
                    width: parent.width
                    spacing: 6

                    Row {
                        width: parent.width
                        Text {
                            text: "󰂯  Bluetooth"
                            color: "#89b4fa"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            id: btStatusText
                            anchors.right: parent.right
                            text: "OFF"
                            color: nixPill.isBtOn ? "#89b4fa" : "#f38ba8"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Process {
                        id: btCheckProc
                        running: true
                        command: ["sh", "-c", "while true; do if rfkill list bluetooth 2>/dev/null | grep -q 'Soft blocked: yes' || ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then echo 'OFF'; else dev=$(bluetoothctl info 2>/dev/null | grep 'Name:' | cut -d: -f2 | xargs); [ -n \"$dev\" ] && echo \"ON ($dev)\" || echo \"ON (Disconnected)\"; fi; sleep 2; done"]
                        stdout: SplitParser { onRead: (data) => { btStatusText.text = data.trim() } }
                    }

                    Row {
                        width: parent.width
                        spacing: 8

                        Rectangle {
                            width: (parent.width - 8) / 2; height: 32; radius: 6
                            color: {
                                if (nixPill.isBtOn) {
                                    return btToggleMouse.containsMouse ? "#b4befe" : "#89b4fa"
                                }
                                return btToggleMouse.containsMouse ? "#313244" : "#2a2b3d"
                            }
                            Row {
                                anchors.centerIn: parent; spacing: 6
                                Text { 
                                    text: "󰂯" 
                                    color: nixPill.isBtOn ? "#1e1e2e" : "#89b4fa"
                                    font.pixelSize: 13
                                    font.family: "JetBrainsMono Nerd Font" 
                                }
                                Text { 
                                    text: "Toggle" 
                                    color: nixPill.isBtOn ? "#1e1e2e" : "#cdd6f4"
                                    font.pixelSize: 12
                                    font.bold: nixPill.isBtOn
                                    font.family: "JetBrainsMono Nerd Font" 
                                }
                            }
                            MouseArea {
                                id: btToggleMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    nixPill.runCmd(btToggleProc, "rfkill toggle bluetooth || (bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on)")
                                    btCheckProc.running = false
                                    btCheckProc.running = true
                                }
                            }
                        }

                        Rectangle {
                            width: (parent.width - 8) / 2; height: 32; radius: 6
                            color: btAppMouse.containsMouse ? "#313244" : "#2a2b3d"
                            Row {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "󰒓"; color: "#89b4fa"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: "Settings"; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            }
                            MouseArea {
                                id: btAppMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    nixPill.runCmd(btAppProc, "blueman-manager || kitty -e bluetoothctl")
                                    nixMenuPopup.visible = false
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#313244" }

                // ------------------------------------------
                // 4. QUICK SHORTCUTS
                // ------------------------------------------
                Row {
                    spacing: 8
                    width: parent.width

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 32; radius: 6
                        color: btn1Mouse.containsMouse ? "#313244" : "#2a2b3d"
                        Row {
                            anchors.centerIn: parent; spacing: 6
                            Text { text: "󰓃"; color: "#a6e3a1"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                            Text { text: "Audio"; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                        }
                        Process { id: audioProc; command: ["pavucontrol"] }
                        MouseArea {
                            id: btn1Mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { audioProc.running = true; nixMenuPopup.visible = false }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 32; radius: 6
                        color: btn2Mouse.containsMouse ? "#313244" : "#2a2b3d"
                        Row {
                            anchors.centerIn: parent; spacing: 6
                            Text { text: "󰌾"; color: "#f38ba8"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                            Text { text: "Lock"; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                        }
                        Process { id: lockProc; command: ["hyprlock"] }
                        MouseArea {
                            id: btn2Mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { lockProc.running = true; nixMenuPopup.visible = false }
                        }
                    }
                }
            }
        }
    }
}
