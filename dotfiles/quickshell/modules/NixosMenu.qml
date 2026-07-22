import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: nixPill
    color: "transparent"
    
    implicitWidth: 42
    implicitHeight: 32

    // NixOS Logo Icon
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
        onClicked: nixMenuPopup.visible = !nixMenuPopup.visible
    }

    // Command Execution Processes
    Process { id: setBrightnessProc }
    Process { id: wifiToggleProc }
    Process { id: wifiAppProc }
    Process { id: btToggleProc }
    Process { id: btAppProc }

    // Helper to safely execute terminal commands in Quickshell
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
                        text: "NixOS Settings"
                        color: "#cdd6f4"
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#313244" }

                // ------------------------------------------
                // 1. SCREEN BRIGHTNESS
                // ------------------------------------------
                Column {
                    width: parent.width
                    spacing: 6

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
                            id: brightnessText
                            anchors.right: parent.right
                            text: "100%"
                            color: "#cdd6f4"
                            font.pixelSize: 13
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Process {
                        running: true
                        command: ["sh", "-c", "while true; do brightnessctl -m 2>/dev/null | cut -d, -f4; sleep 1; done"]
                        stdout: SplitParser { onRead: (data) => brightnessText.text = data.trim() }
                    }

                    Row {
                        width: parent.width
                        spacing: 6

                        Rectangle {
                            width: 32; height: 28; radius: 6
                            color: decMouse.containsMouse ? "#313244" : "#2a2b3d"
                            Text { anchors.centerIn: parent; text: "󰃞"; color: "#f9e2af"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            MouseArea { id: decMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nixPill.runCmd(setBrightnessProc, "brightnessctl set 5%-") }
                        }

                        Repeater {
                            model: [25, 50, 75, 100]
                            delegate: Rectangle {
                                width: 44; height: 28; radius: 6
                                color: presetMouse.containsMouse ? "#89b4fa" : "#2a2b3d"
                                Text { anchors.centerIn: parent; text: modelData + "%"; color: presetMouse.containsMouse ? "#1e1e2e" : "#cdd6f4"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                                MouseArea { id: presetMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nixPill.runCmd(setBrightnessProc, "brightnessctl set " + modelData + "%") }
                            }
                        }

                        Rectangle {
                            width: 32; height: 28; radius: 6
                            color: incMouse.containsMouse ? "#313244" : "#2a2b3d"
                            Text { anchors.centerIn: parent; text: "󰃠"; color: "#f9e2af"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            MouseArea { id: incMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nixPill.runCmd(setBrightnessProc, "brightnessctl set +5%") }
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
                            color: wifiStatusText.text.indexOf("ON") !== -1 ? "#a6e3a1" : "#f38ba8"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    // Checks Wi-Fi status and connected SSID
                    Process {
                        id: wifiCheckProc
                        running: true
                        command: ["sh", "-c", "while true; do if rfkill list wlan 2>/dev/null | grep -q 'Soft blocked: yes'; then echo 'OFF'; else SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2); if [ -n \"$SSID\" ]; then echo \"ON ($SSID)\"; else echo \"ON (Disconnected)\"; fi; fi; sleep 2; done"]
                        stdout: SplitParser { onRead: (data) => wifiStatusText.text = data.trim() }
                    }

                    Row {
                        width: parent.width
                        spacing: 8

                        // Toggle Button
                        Rectangle {
                            width: (parent.width - 8) / 2; height: 32; radius: 6
                            color: wifiToggleMouse.containsMouse ? "#313244" : "#2a2b3d"
                            Row {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "󰤨"; color: "#a6e3a1"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: "Toggle"; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
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

                        // Settings Button
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
                            color: btStatusText.text.indexOf("ON") !== -1 ? "#89b4fa" : "#f38ba8"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Process {
                        id: btCheckProc
                        running: true
                        command: ["sh", "-c", "while true; do if rfkill list bluetooth 2>/dev/null | grep -q 'Soft blocked: yes' || ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then echo 'OFF'; else dev=$(bluetoothctl info 2>/dev/null | grep 'Name:' | cut -d: -f2 | xargs); [ -n \"$dev\" ] && echo \"ON ($dev)\" || echo 'ON (Disconnected)'; fi; sleep 2; done"]
                        stdout: SplitParser { onRead: (data) => btStatusText.text = data.trim() }
                    }

                    Row {
                        width: parent.width
                        spacing: 8

                        // Toggle Button
                        Rectangle {
                            width: (parent.width - 8) / 2; height: 32; radius: 6
                            color: btToggleMouse.containsMouse ? "#313244" : "#2a2b3d"
                            Row {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "󰂯"; color: "#89b4fa"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: "Toggle"; color: "#cdd6f4"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
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

                        // Settings Button
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

                    // Audio Mixer
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

                    // Lock Screen
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
