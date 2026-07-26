import QtQuick
import QtQuick.Controls
import Quickshell

PopupWindow {
    id: modalRoot

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    grabFocus: true
    visible: false
    color: "transparent"

    property string title: "Modal Dialog"
    property string message: ""
    property Component contentComponent: null
    signal accepted()
    signal rejected()

    implicitWidth: 380
    implicitHeight: mainCard.implicitHeight

    Rectangle {
        id: mainCard
        width: parent.width
        implicitHeight: contentColumn.implicitHeight + 32
        color: "#1e1e2e"
        border.color: "#89b4fa"
        border.width: 1
        radius: 12
        clip: true

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        Column {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            Row {
                width: parent.width
                spacing: 8
                Text {
                    text: "󰅩"
                    color: "#89b4fa"
                    font.pixelSize: 18
                    font.family: "JetBrainsMono Nerd Font"
                }
                Text {
                    text: modalRoot.title
                    color: "#cdd6f4"
                    font.pixelSize: 15
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#313244" }

            Text {
                visible: modalRoot.message !== ""
                width: parent.width
                text: modalRoot.message
                color: "#a6adc8"
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font"
                wrapMode: Text.Wrap
            }

            Loader {
                width: parent.width
                sourceComponent: modalRoot.contentComponent
            }

            Row {
                anchors.right: parent.right
                spacing: 10

                Rectangle {
                    width: 80; height: 30; radius: 6
                    color: cancelMouse.containsMouse ? "#313244" : "#2a2b3d"
                    Text {
                        anchors.centerIn: parent; text: "Cancel"; color: "#f38ba8"
                        font.pixelSize: 12; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                    }
                    MouseArea {
                        id: cancelMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.rejected()
                            modalRoot.visible = false
                        }
                    }
                }

                Rectangle {
                    width: 80; height: 30; radius: 6
                    color: confirmMouse.containsMouse ? "#8ce187" : "#a6e3a1"
                    Text {
                        anchors.centerIn: parent; text: "Confirm"; color: "#1e1e2e"
                        font.pixelSize: 12; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                    }
                    MouseArea {
                        id: confirmMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.accepted()
                            modalRoot.visible = false
                        }
                    }
                }
            }
        }
    }
}
