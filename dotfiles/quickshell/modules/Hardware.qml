import QtQuick
import Quickshell
import Quickshell.Io
import qs.components

Rectangle {
    id: hardwarePill
    color: "#99313244"
    radius: 8
    implicitWidth: hardwareRow.implicitWidth + 24
    implicitHeight: 32

    Row {
        id: hardwareRow
        anchors.centerIn: parent
        spacing: 15

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Process {
                running: true
                command: ["sh", "-c", "while true; do vmstat 1 2 | tail -1 | awk '{print 100 - $15\"%\"}'; sleep 2; done"]
                stdout: SplitParser {
                    onRead: (data) => cpuText.text = data.trim()
                }
            }
            Text {
                text: ""
                color: "#94e2d5"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: cpuText
                text: "..."
                color: "#94e2d5"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Process {
                running: true
                command: ["sh", "-c", "while true; do hw=$(grep -lE 'k10temp|zenpower|coretemp' /sys/class/hwmon/hwmon*/name 2>/dev/null | head -n 1 | sed 's|/name||'); t=\"\"; if [ -n \"$hw\" ]; then lbl=$(grep -lE 'Tccd1|Tdie' \"$hw\"/temp*_label 2>/dev/null | head -n 1); [ -n \"$lbl\" ] && t=$(cat \"${lbl%label}input\" 2>/dev/null); [ -z \"$t\" ] && t=$(cat \"$hw\"/temp1_input 2>/dev/null); fi; [ -z \"$t\" ] && t=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1); if [ -n \"$t\" ] && [ \"$t\" -gt 0 ]; then echo $((t / 1000))\"°C\"; else echo '?°C'; fi; sleep 5; done"]
                stdout: SplitParser {
                    onRead: (data) => { tempText.text = data.trim() }
                }
            }
            Text {
                text: ""
                color: "#fab387"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: tempText
                text: "..."
                color: "#fab387"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Process {
                running: true
                command: ["sh", "-c", "while true; do free -h | awk '/^Mem:/ {print $3}' | sed 's/i//g'; sleep 2; done"]
                stdout: SplitParser {
                    onRead: (data) => memText.text = data.trim()
                }
            }
            Text {
                text: ""
                color: "#cba6f7"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: memText
                text: "..."
                color: "#cba6f7"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: hwPopup.visible = !hwPopup.visible
    }

    PopupWindow {
        id: hwPopup
        anchor.item: hardwarePill
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: false
        grabFocus: true
        color: "transparent"

        implicitWidth: 380
        implicitHeight: 380

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: "#313244"
            border.width: 1
            radius: 12

            ProcessView {
                anchors.fill: parent
                anchors.margins: 14
                visible: hwPopup.visible
            }
        }
    }
}
