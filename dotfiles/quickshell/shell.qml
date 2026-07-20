import QtQuick
import QtQml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire

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
                color: "#1e1e2e" // Catppuccin Base
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
                        onTriggered: timeText.text = Qt.formatDateTime(new Date(), "HH:mm   MM-dd")
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
                // RIGHT: Tray, Volume, & Wlogout
                // ==========================================
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 15
                    spacing: 15

                    Process {
                        id: swayncProc
                        command: ["swaync-client", "-t", "-sw"]
                    }

                    Process {
                        id: wlogoutProc
                        command: ["wlogout", "-b", "5", "-T", "400", "-B", "400"]
                    }

                    // Audio / Volume Module Sandbox
                    Item {
                        // Dynamically size the sandbox to fit the text inside
                        implicitWidth: volRow.width
                        implicitHeight: volRow.height

                        // Strong QML Binding: Actively tracks Pipewire state
                        property var audioNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null

                        Row {
                            id: volRow
                            spacing: 6

                            Text {
                                text: {
                                    if (!parent.parent.audioNode || parent.parent.audioNode.muted) return "󰝟"
                                    if (parent.parent.audioNode.volume > 0.66) return "󰕾"
                                    if (parent.parent.audioNode.volume > 0.33) return "󰖀"
                                    return "󰕿"
                                }
                                color: "#cdd6f4"
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            Text {
                                // Automatically updates whenever audioNode.volume changes
                                text: parent.parent.audioNode ? Math.round(parent.parent.audioNode.volume * 100) + "%" : "0%"
                                color: "#cdd6f4"
                                font.pixelSize: 16
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        // MouseArea safely anchors to the Item wrapper, avoiding the Row Layout
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onWheel: (wheel) => {
                                let node = parent.audioNode
                                if (!node) return;
                                
                                if (wheel.angleDelta.y > 0) {
                                    node.volume = Math.min(1.0, node.volume + 0.05)
                                } else {
                                    node.volume = Math.max(0.0, node.volume - 0.05)
                                }
                            }

                            onClicked: (mouse) => {
                                if (mouse.button === Qt.RightButton) {
                                    let node = parent.audioNode
                                    if (node) node.muted = !node.muted
                                } else {
                                    swayncProc.running = true
                                }
                            }
                        }
                    }

                    // Wlogout Button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 4
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: "#f38ba8"
                            font.pixelSize: 18
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
