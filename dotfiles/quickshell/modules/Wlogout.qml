import QtQuick
import Quickshell.Io

Item {
    width: 28
    height: 28

    Process {
        id: wlogoutProc
        command: ["wlogout", "-b", "5", "-T", "400", "-B", "400"]
    }

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: "transparent"
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
