import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: pmWindow
    objectName: "powerMenu"
    signal closeRequested()

    property bool isActiveScreen: false

    WlrLayershell.namespace: "powermenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: pmWindow.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true; bottom: true; left: true; right: true
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    Process { id: actionProc }

    Shortcut {
        sequence: "Escape"
        enabled: pmWindow.visible
        onActivated: pmWindow.closeRequested()
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: "#d911111b"

        focus: true

        Connections {
            target: pmWindow
            function onVisibleChanged() {
                if (pmWindow.visible) bgRect.forceActiveFocus()
            }
        }

        Keys.onEscapePressed: (event) => {
            pmWindow.closeRequested()
            event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: pmWindow.closeRequested()
        }

        Loader {
            anchors.fill: parent
            active: pmWindow.isActiveScreen
            sourceComponent: menuContent
        }
    }

    Component {
        id: menuContent
        Item {
            anchors.fill: parent

            property string currentTime: ""
            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    currentTime = Qt.formatTime(new Date(), "hh:mm");
                }
            }

            Text {
                anchors.top: parent.top
                anchors.topMargin: 120
                anchors.horizontalCenter: parent.horizontalCenter
                text: currentTime
                color: "#cdd6f4"
                font.pixelSize: 84
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                renderType: Text.NativeRendering
            }

            ListModel {
                id: powerModel
                ListElement { icon: "󰌾"; label: "Lock"; accent: "#f5e0dc"; cmd: "loginctl lock-session" }
                ListElement { icon: "󰍃"; label: "Logout"; accent: "#f9e2af"; cmd: "loginctl terminate-user $USER" }
                ListElement { icon: "󰒲"; label: "Suspend"; accent: "#a6e3a1"; cmd: "systemctl suspend" }
                ListElement { icon: "󰑐"; label: "Reboot"; accent: "#89b4fa"; cmd: "systemctl reboot" }
                ListElement { icon: "󰐥"; label: "Shutdown"; accent: "#f38ba8"; cmd: "systemctl poweroff" }
            }

            Row {
                anchors.centerIn: parent
                spacing: 24

                Repeater {
                    model: powerModel
                    delegate: Rectangle {
                        id: btn
                        width: 140
                        height: 140
                        radius: 16

                        color: btnMouse.containsMouse ? model.accent : "#2a2b3d"

                        Column {
                            anchors.centerIn: parent
                            spacing: 16

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: model.icon
                                color: btnMouse.containsMouse ? "#1e1e2e" : model.accent
                                font.pixelSize: 48
                                font.family: "JetBrainsMono Nerd Font"
                                renderType: Text.NativeRendering
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: model.label
                                color: btnMouse.containsMouse ? "#1e1e2e" : "#cdd6f4"
                                font.pixelSize: 16
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                renderType: Text.NativeRendering
                            }
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                pmWindow.closeRequested()
                                actionProc.running = false
                                actionProc.command = ["sh", "-c", model.cmd]
                                actionProc.running = true
                            }
                        }
                    }
                }
            }
        }
    }
}
