import QtQuick
import QtQml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "./modules"

ShellRoot {
    id: shellRoot

    property var activePowerScreen: null

    IpcHandler {
        target: "powermenu"
        function toggle(): void {
            if (shellRoot.activePowerScreen !== null) {
                shellRoot.activePowerScreen = null;
            } else {
                let focusedName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
                let matchedScreen = null;

                for (let i = 0; i < Quickshell.screens.length; i++) {
                    if (Quickshell.screens[i].name === focusedName) {
                        matchedScreen = Quickshell.screens[i];
                        break;
                    }
                }

                shellRoot.activePowerScreen = matchedScreen !== null ? matchedScreen : Quickshell.screens[0];
            }
        }
    }

    Instantiator {
        model: Quickshell.screens
        delegate: PowerMenu {
            screen: modelData
            visible: shellRoot.activePowerScreen !== null
            isActiveScreen: shellRoot.activePowerScreen === modelData
            onCloseRequested: shellRoot.activePowerScreen = null
        }
    }

    Instantiator {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: topBar
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 40
            exclusionMode: ExclusionMode.Auto

            Rectangle {
                anchors.fill: parent
                color: "#771e1e2e" 

                // ==========================================
                // LEFT: Workspaces & System Tray
                // ==========================================
                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 15
                    spacing: 20
                    NixosMenu { anchors.verticalCenter: parent.verticalCenter }
                    Workspaces { anchors.verticalCenter: parent.verticalCenter }
                    SystemTrayModule { anchors.verticalCenter: parent.verticalCenter }
                }
                // ==========================================
                // CENTER: Clock
                // ==========================================
                Clock {
                    anchors.centerIn: parent
                }
                // ==========================================
                // RIGHT: Hardware, Volume, Wlogout
                // ==========================================
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 18
                    spacing: 15
                    Laptop { anchors.verticalCenter: parent.verticalCenter }
                    Hardware { anchors.verticalCenter: parent.verticalCenter }
                    Volume { anchors.verticalCenter: parent.verticalCenter }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        radius: 4
                        color: pwrBtnMouse.containsMouse ? "#313244" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "⏻"
                            color: "#f38ba8"
                            font.pixelSize: 17
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            id: pwrBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (shellRoot.activePowerScreen === topBar.screen) {
                                    shellRoot.activePowerScreen = null
                                } else {
                                    shellRoot.activePowerScreen = topBar.screen
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
