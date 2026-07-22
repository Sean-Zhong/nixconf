import QtQuick
import Quickshell.Hyprland

Row {
    spacing: 8
    visible: Hyprland.activeWindow !== null && Hyprland.activeWindow.title !== ""

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "" 
        color: "#89b4fa"
        font.pixelSize: 16
        font.family: "JetBrainsMono Nerd Font"
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Hyprland.activeWindow ? Hyprland.activeWindow.title : ""

        color: "#ffffff"
        font.pixelSize: 14
        font.family: "JetBrainsMono Nerd Font"
        font.bold: true

        width: Math.min(300, contentWidth)
        elide: Text.ElideRight
        clip: true
    }
}
