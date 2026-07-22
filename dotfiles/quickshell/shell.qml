import QtQuick
import QtQml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Widgets

ShellRoot {
    Instantiator {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: topBar
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 40
            exclusionMode: ExclusionMode.Auto

            Rectangle {
                anchors.fill: parent
                color: "#1e1e2e"
                border.color: "#313244"
                border.width: 2

                // ==========================================
                // LEFT: Workspaces & Active Window
                // ==========================================
                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 15
                    spacing: 20

                    Row {
                        spacing: 6
                        Repeater {
                            model: Hyprland.workspaces
                            delegate: Rectangle {
                                required property var modelData
                                width: 28
                                height: 28
                                radius: 14
                                color: modelData.focused ? "#cdd6f4" : "#313244"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: modelData.focused ? "#11111b" : "#cdd6f4"
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.activate()
                                }
                            }
                        }
                    }

                    Text {
                        text: Hyprland.activeWindow ? Hyprland.activeWindow.title : ""
                        color: "#bac2de"
                        font.pixelSize: 15
                        font.family: "JetBrainsMono Nerd Font"
                        width: 350
                        elide: Text.ElideRight
                        clip: true
                    }
                }

                // ==========================================
                // CENTER: Clock Module
                // ==========================================
                Row {
                    anchors.centerIn: parent

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: timeText.text = Qt.formatDateTime(new Date(), "HH:mm  MM-dd")
                    }

                    Text {
                        id: timeText
                        text: Qt.formatDateTime(new Date(), "HH:mm   MM-dd")
                        color: "#cdd6f4"
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                    }
                }

                // ==========================================
                // RIGHT: System Info, Tray, Volume, Wlogout
                // ==========================================
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 18
                    spacing: 15

                    Process {
                        id: swayncProc
                        command: ["swaync-client", "-t", "-sw"]
                    }

                    Process {
                        id: wlogoutProc
                        command: ["wlogout", "-b", "5", "-T", "400", "-B", "400"]
                    }

                    // ==========================================
                    // 1. System Tray Module (Crash-Proof ListView Menu!)
                    // ==========================================
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Repeater {
                            model: SystemTray.items

                            delegate: Item {
                                required property var modelData
                                width: 20
                                height: 20
                                anchors.verticalCenter: parent.verticalCenter

                                readonly property bool isNet: (modelData.id && (modelData.id.toLowerCase().includes("nm-") || modelData.id.toLowerCase().includes("network"))) || (modelData.title && modelData.title.toLowerCase().includes("network"))
                                readonly property bool isBlue: (modelData.id && modelData.id.toLowerCase().includes("blue")) || (modelData.title && modelData.title.toLowerCase().includes("bluetooth"))

                                Text {
                                    anchors.centerIn: parent
                                    visible: parent.isNet || parent.isBlue
                                    text: parent.isNet ? "󰈀" : "󰂯"
                                    color: "#cdd6f4"
                                    font.pixelSize: 16
                                    font.family: "JetBrainsMono Nerd Font"
                                }

                                IconImage {
                                    anchors.fill: parent
                                    visible: !parent.isNet && !parent.isBlue
                                    source: (!parent.isNet && !parent.isBlue) ? modelData.icon : ""
                                }

                                QsMenuOpener {
                                    id: menuOpener
                                    menu: modelData.hasMenu ? modelData.menu : null
                                }

                                PopupWindow {
                                    id: customMenuPopup
                                    anchor.item: parent
                                    anchor.edges: Edges.Bottom
                                    anchor.gravity: Edges.Bottom
                                    visible: false
                                    grabFocus: true
                                    color: "transparent"

                                    implicitWidth: 220
                                    implicitHeight: Math.min(400, menuList.contentHeight + 16)

                                    Rectangle {
                                        id: menuCard
                                        anchors.fill: parent
                                        color: "#1e1e2e"
                                        border.color: "#313244"
                                        border.width: 1
                                        radius: 6

                                        ListView {
                                            id: menuList
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 4
                                            clip: true
                                            model: menuOpener.children

                                            delegate: Rectangle {
                                                required property var modelData
                                                width: menuList.width
                                                height: modelData.isSeparator ? 8 : 28
                                                radius: 4
                                                color: itemMouse.containsMouse ? "#313244" : "transparent"
                                                visible: true

                                                Rectangle {
                                                    anchors.centerIn: parent
                                                    width: parent.width - 8
                                                    height: 1
                                                    color: "#313244"
                                                    visible: modelData.isSeparator
                                                }

                                                Text {
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 10
                                                    anchors.right: parent.right
                                                    anchors.rightMargin: 10
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: modelData.text || ""
                                                    color: modelData.enabled ? "#cdd6f4" : "#6c7086"
                                                    font.pixelSize: 13
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    elide: Text.ElideRight
                                                    visible: !modelData.isSeparator
                                                }

                                                MouseArea {
                                                    id: itemMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    enabled: !modelData.isSeparator && modelData.enabled
                                                    cursorShape: Qt.PointingHandCursor

                                                    onClicked: {
                                                        modelData.triggered()
                                                        customMenuPopup.visible = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                                    onClicked: (mouse) => {
                                        if (mouse.button === Qt.RightButton) {
                                            if (modelData.hasMenu) {
                                                customMenuPopup.visible = !customMenuPopup.visible
                                            } else {
                                                modelData.secondaryActivate()
                                            }
                                        } else {
                                            if (modelData.onlyMenu) {
                                                customMenuPopup.visible = !customMenuPopup.visible
                                            } else {
                                                modelData.activate()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

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
                            color: "#cdd6f4"
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            id: cpuText
                            text: "..."
                            color: "#cdd6f4"
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

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
                            color: "#cdd6f4"
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            id: tempText
                            text: "..."
                            color: "#cdd6f4"
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

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
                            color: "#cdd6f4"
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            id: memText
                            text: "..."
                            color: "#cdd6f4"
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Item {
                        id: volumeContainer
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: volRow.implicitWidth
                        implicitHeight: volRow.implicitHeight

                        property var sink: Pipewire.defaultAudioSink

                        PwObjectTracker {
                            objects: volumeContainer.sink ? [volumeContainer.sink] : []
                        }

                        Row {
                            id: volRow
                            anchors.fill: parent
                            spacing: 6

                            Text {
                                text: {
                                    let audio = volumeContainer.sink?.audio
                                    if (!audio || audio.muted) return "󰝟"
                                    if (audio.volume > 0.66) return "󰕾"
                                    if (audio.volume > 0.33) return "󰖀"
                                    return "󰕿"
                                }
                                color: "#cdd6f4"
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            Text {
                                text: {
                                    let audio = volumeContainer.sink?.audio
                                    if (!audio) return "0%"
                                    return Math.round(audio.volume * 100) + "%"
                                }
                                color: "#cdd6f4"
                                font.pixelSize: 16
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onWheel: (wheel) => {
                                let audio = volumeContainer.sink?.audio
                                if (!audio) return;

                                if (wheel.angleDelta.y > 0) {
                                    audio.volume = Math.min(1.0, audio.volume + 0.05)
                                } else {
                                    audio.volume = Math.max(0.0, audio.volume - 0.05)
                                }
                            }

                            onClicked: (mouse) => {
                                if (mouse.button === Qt.RightButton) {
                                    let audio = volumeContainer.sink?.audio
                                    if (audio) audio.muted = !audio.muted
                                } else {
                                    swayncProc.running = true
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 4
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: "#f38ba8"
                            font.pixelSize: 17
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wlogoutProc.running = true
                        }
                    }
                }
            }
        }
    }
}
