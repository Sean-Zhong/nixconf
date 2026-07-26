import QtQuick
import QtQuick.Controls
import Quickshell

PopupWindow {
    id: passModalRoot

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    grabFocus: true
    visible: false
    color: "transparent"

    property string targetSsid: ""
    signal connectRequested(string ssid, string password)

    implicitWidth: 380
    implicitHeight: mainCard.implicitHeight

    onVisibleChanged: {
        if (visible) {
            passInput.text = ""
            passInput.forceActiveFocus()
        }
    }

    Rectangle {
        id: mainCard
        width: parent.width
        implicitHeight: contentCol.implicitHeight + 32
        color: "#1e1e2e"
        border.color: "#89b4fa"
        border.width: 1
        radius: 12

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        Column {
            id: contentCol
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Row {
                spacing: 8
                Text {
                    text: "🔐"
                    font.pixelSize: 16
                }
                Text {
                    text: "Wi-Fi Authentication"
                    color: "#cdd6f4"
                    font.pixelSize: 15
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Text {
                width: parent.width
                text: "Enter password for network: " + passModalRoot.targetSsid
                color: "#a6adc8"
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                wrapMode: Text.Wrap
            }

            Rectangle {
                width: parent.width
                height: 36
                color: "#181825"
                border.color: passInput.activeFocus ? "#89b4fa" : "#313244"
                border.width: 1
                radius: 6

                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.margins: 8
                    color: "#cdd6f4"
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                    echoMode: TextInput.Password
                    onAccepted: {
                        passModalRoot.connectRequested(passModalRoot.targetSsid, passInput.text)
                        passInput.text = ""
                        passModalRoot.visible = false
                    }
                }
            }

            Row {
                anchors.right: parent.right
                spacing: 10

                Rectangle {
                    width: 80; height: 30; radius: 6
                    color: cancelM.containsMouse ? "#313244" : "#2a2b3d"
                    Text {
                        anchors.centerIn: parent; text: "Cancel"; color: "#f38ba8"
                        font.pixelSize: 12; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                    }
                    MouseArea {
                        id: cancelM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            passInput.text = ""
                            passModalRoot.visible = false
                        }
                    }
                }

                Rectangle {
                    width: 80; height: 30; radius: 6
                    color: okM.containsMouse ? "#8ce187" : "#a6e3a1"
                    Text {
                        anchors.centerIn: parent; text: "Connect"; color: "#1e1e2e"
                        font.pixelSize: 12; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                    }
                    MouseArea {
                        id: okM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            passModalRoot.connectRequested(passModalRoot.targetSsid, passInput.text)
                            passInput.text = ""
                            passModalRoot.visible = false
                        }
                    }
                }
            }
        }
    }
}
