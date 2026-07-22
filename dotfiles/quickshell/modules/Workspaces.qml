import QtQuick
import Quickshell.Hyprland

Row {
    id: workspaceRow
    spacing: 4

    Repeater {
        model: Hyprland.workspaces
        delegate: Rectangle {
            required property var modelData
            width: 26
            height: 26
            radius: 4
            color: modelData.focused ? "#89b4fa" : "transparent"

            Text {
                anchors.centerIn: parent
                text: modelData.name

                color: modelData.focused ? "#1e1e2e" : "#ffffff"
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
