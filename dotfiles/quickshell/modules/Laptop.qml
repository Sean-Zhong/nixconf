import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: laptopModule
    color: "#99313244"
    radius: 8

    visible: hasBattery
    implicitWidth: visible ? (laptopRow.implicitWidth + 24) : 0
    implicitHeight: 32

    property bool hasBattery: false
    property int batPercent: 100
    property string batStatus: "Discharging"
    property string brightnessPercent: "100%"

    Process {
        running: true
        command: ["sh", "-c", "[ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ] && echo 'yes' || echo 'no'"]
        stdout: SplitParser {
            onRead: (data) => laptopModule.hasBattery = (data.trim() === "yes")
        }
    }

    Process {
        running: laptopModule.hasBattery
        command: ["sh", "-c", "while true; do bat=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1); stat=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1); echo \"$bat|$stat\"; sleep 3; done"]
        stdout: SplitParser {
            onRead: (data) => {
                let parts = data.trim().split("|")
                if (parts.length >= 2) {
                    laptopModule.batPercent = parseInt(parts[0]) || 0
                    laptopModule.batStatus = parts[1].trim()
                }
            }
        }
    }

    Process {
        running: laptopModule.hasBattery
        command: ["sh", "-c", "while true; do brightnessctl -m 2>/dev/null | cut -d, -f4; sleep 1; done"]
        stdout: SplitParser {
            onRead: (data) => laptopModule.brightnessPercent = data.trim()
        }
    }

    Row {
        id: laptopRow
        anchors.centerIn: parent
        spacing: 12

        // ------------------------------------------
        // BRIGHTNESS DISPLAY (Catppuccin Yellow/Peach)
        // ------------------------------------------
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                text: {
                    let b = parseInt(laptopModule.brightnessPercent) || 100
                    if (b > 66) return "󰃠"
                    if (b > 33) return "󰃟"
                    return "󰃞"
                }
                color: "#f9e2af"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }

            Text {
                text: laptopModule.brightnessPercent
                color: "#f9e2af"
                font.pixelSize: 15
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        // ------------------------------------------
        // BATTERY DISPLAY (Catppuccin Green / Red Low)
        // ------------------------------------------
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                text: {
                    if (laptopModule.batStatus === "Charging") return "󰂄"
                    let p = laptopModule.batPercent
                    if (p >= 90) return "󰁹"
                    if (p >= 70) return "󰂀"
                    if (p >= 50) return "󰁾"
                    if (p >= 30) return "󰁼"
                    if (p >= 15) return "󰁺"
                    return "󰂎"
                }
                color: {
                    if (laptopModule.batStatus === "Charging") return "#a6e3a1"
                    if (laptopModule.batPercent <= 15) return "#f38ba8" // Warning Red
                    return "#a6e3a1"
                }
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }

            Text {
                text: laptopModule.batPercent + "%"
                color: laptopModule.batPercent <= 15 && laptopModule.batStatus !== "Charging" ? "#f38ba8" : "#a6e3a1"
                font.pixelSize: 15
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onWheel: (wheel) => {
            let cmd = wheel.angleDelta.y > 0 ? "brightnessctl set +5%" : "brightnessctl set 5%-"
            brightProc.running = false
            brightProc.command = ["sh", "-c", cmd]
            brightProc.running = true
        }
    }

    Process { id: brightProc }
}
