import QtQuick
import Quickshell.Io

Rectangle {
    id: hardwarePill

    color: "#99313244"

    radius: 16

    implicitWidth: hardwareRow.implicitWidth + 24
    implicitHeight: 32

    Row {
        id: hardwareRow
        anchors.centerIn: parent
        spacing: 15

        // ==========================================
        // 1. CPU Module
        // ==========================================
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Process {
                running: true
                command: ["sh", "-c", "while true; do vmstat 1 2 | tail -1 | awk '{print 100 - $15\"%\"}'; sleep 2; done"]
                stdout: SplitParser {
                    onRead: (data) => cpuText.text = data
                }
            }
            Text {
                text: ""
                color: "#ffffff" // Pure white
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: cpuText
                text: "..."
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        // ==========================================
        // 2. Temperature Module
        // ==========================================
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Process {
                running: true
                command: ["sh", "-c", "while true; do cat $(grep -lE 'k10temp|zenpower' /sys/class/hwmon/hwmon*/name 2>/dev/null | sed 's/name/temp3_input/') 2>/dev/null | head -n 1 | awk '{print int($1/1000)\"°C\"}' || echo '?°C'; sleep 5; done"]
                stdout: SplitParser {
                    onRead: (data) => tempText.text = data
                }
            }
            Text {
                text: ""
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: tempText
                text: "..."
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        // ==========================================
        // 3. Memory Module
        // ==========================================
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Process {
                running: true
                command: ["sh", "-c", "while true; do free -h | awk '/^Mem:/ {print $3}' | sed 's/i//g'; sleep 2; done"]
                stdout: SplitParser {
                    onRead: (data) => memText.text = data
                }
            }
            Text {
                text: ""
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: memText
                text: "..."
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }
}
