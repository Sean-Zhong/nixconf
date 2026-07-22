import QtQuick
import QtQml
import Quickshell
import Quickshell.Wayland
import "./modules"

ShellRoot {
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
                    Wlogout { anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }
    }
}
