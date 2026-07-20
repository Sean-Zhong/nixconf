import QtQuick
import QtQuick.Layouts
import QtQml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

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
                border.color: "#313244" // Catppuccin Surface0
                border.width: 2

                // ==========================================
                // LEFT: Hyprland Workspaces Module
                // ==========================================
                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 15
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

                // ==========================================
                // CENTER: Clock Module
                // ==========================================
                RowLayout {
                    anchors.centerIn: parent
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: {
                            // Formatted to match your old waybar style: HH:mm  MM-dd
                            timeText.text = Qt.formatDateTime(new Date(), "HH:mm  MM-dd")
                        }
                    }

                    Text {
                        id: timeText
                        text: Qt.formatDateTime(new Date(), "HH:mm  MM-dd")
                        color: "#cdd6f4"
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                    }
                }

                // ==========================================
                // RIGHT: System Tray & Wlogout
                // ==========================================
                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 15
                    spacing: 15

                    // Defines the terminal command to run
                    Process {
                        id: wlogoutProc
                        command: ["wlogout", "-b", "5", "-T", "400", "-B", "400"]
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
