    PanelWindow {
        id: topBar
        // Reference to the specific screen this instance is rendering on
        property var screenModel: modelData
        
        /* STREAMING_CHUNK:Configuring Wayland Layer Shell properties... */
        screen: screenModel
        anchors {
            top: true
            left: true
            right: true
        }
        height: 40 // Matches your old Waybar height
        
        // Tells Hyprland to reserve space so tiled windows don't overlap
        exclusionMode: LayerShell.Exclusive
        layer: LayerShell.Top

        /* STREAMING_CHUNK:Styling the main background container... */
        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e" // Catppuccin Base
            border.color: "#313244" // Catppuccin Surface0
            border.width: 2 // Matches your general hyprland aesthetic

            /* STREAMING_CHUNK:Building the layout structure... */
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 10

                // ==========================================
                // LEFT: Hyprland Workspaces Module
                // ==========================================
                /* STREAMING_CHUNK:Creating the Hyprland Workspaces module... */
                RowLayout {
                    spacing: 6
                    Layout.alignment: Qt.AlignLeft

                    Repeater {
                        // Native Quickshell integration with Hyprland IPC
                        model: Hyprland.workspaces
                        
                        delegate: Rectangle {
                            required property var modelData
                            width: 28
                            height: 28
                            radius: 14 // Makes them circles
                            
                            // Dynamic colors based on active workspace
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
                                onClicked: Hyprland.dispatch(`workspace ${modelData.id}`)
                            }
                        }
                    }
                }

                // ==========================================
                // CENTER: Flexible Spacer
                // ==========================================
                /* STREAMING_CHUNK:Adding a flexible spacer... */
                Item {
                    Layout.fillWidth: true
                }

                // ==========================================
                // RIGHT: Clock Module
                // ==========================================
                /* STREAMING_CHUNK:Creating the Clock module... */
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: {
                            // Simple time format matching your waybar {0:%R}
                            timeText.text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
                        }
                    }

                    Text {
                        id: timeText
                        text: new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
                        color: "#cdd6f4" // Catppuccin Text
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                    }
                }
            }
        }
    }
}

