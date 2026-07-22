import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Rectangle {
    id: trayPill
    color: "transparent"
    radius: 16
    implicitWidth: trayRow.implicitWidth + 24
    implicitHeight: 32

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: SystemTray.items
            delegate: Item {
                required property var modelData
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                readonly property bool isNet: (modelData.id && (modelData.id.toLowerCase().includes("nm-") || modelData.id.toLowerCase().includes("network"))) || (modelData.title && modelData.title.toLowerCase().includes("network"))
                readonly property bool isBlue: (modelData.id && modelData.id.toLowerCase().includes("blue")) || (modelData.title && modelData.title.toLowerCase().includes("bluetooth"))

                Text {
                    anchors.centerIn: parent
                    visible: parent.isNet || parent.isBlue
                    text: parent.isNet ? "󰈀" : "󰂯"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                }

                IconImage {
                    anchors.fill: parent
                    visible: !parent.isNet && !parent.isBlue
                    source: (!parent.isNet && !parent.isBlue) ? modelData.icon : ""
                }

                QsMenuOpener {
                    id: menuOpener
                    menu: modelData.hasMenu ? modelData.menu : null
                }

                PopupWindow {
                    id: customMenuPopup
                    anchor.item: parent
                    anchor.edges: Edges.Bottom
                    anchor.gravity: Edges.Bottom
                    visible: false
                    grabFocus: true
                    color: "transparent"
                    implicitWidth: 220
                    implicitHeight: Math.min(400, menuList.contentHeight + 16)

                    Rectangle {
                        id: menuCard
                        anchors.fill: parent
                        color: "#1e1e2e"
                        border.color: "#313244"
                        border.width: 1
                        radius: 6

                        ListView {
                            id: menuList
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4
                            clip: true
                            model: menuOpener.children
                            delegate: Rectangle {
                                required property var modelData
                                width: menuList.width
                                height: modelData.isSeparator ? 8 : 28
                                radius: 4
                                color: itemMouse.containsMouse ? "#313244" : "transparent"
                                visible: true

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width - 8
                                    height: 1
                                    color: "#313244"
                                    visible: modelData.isSeparator
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.text || ""
                                    color: modelData.enabled ? "#cdd6f4" : "#6c7086"
                                    font.pixelSize: 13
                                    font.family: "JetBrainsMono Nerd Font"
                                    elide: Text.ElideRight
                                    visible: !modelData.isSeparator
                                }

                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: !modelData.isSeparator && modelData.enabled
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        modelData.triggered()
                                        customMenuPopup.visible = false
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            if (modelData.hasMenu) {
                                customMenuPopup.visible = !customMenuPopup.visible
                            } else {
                                modelData.secondaryActivate()
                            }
                        } else {
                            if (modelData.onlyMenu) {
                                customMenuPopup.visible = !customMenuPopup.visible
                            } else {
                                modelData.activate()
                            }
                        }
                    }
                }
            }
        }
    }
}
