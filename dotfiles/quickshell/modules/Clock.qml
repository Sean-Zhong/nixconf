import QtQuick
import Quickshell
import qs.components

Rectangle {
    id: clockPill
    color: "transparent"
    radius: 16
    implicitWidth: clockRow.implicitWidth + 24
    implicitHeight: 32

    property var now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockPill.now = new Date()
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clockPill.now, "HH:mm")
            color: "#ffffff"
            font.pixelSize: 20
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: calendarPopup.visible = !calendarPopup.visible
    }

    PopupWindow {
        id: calendarPopup
        anchor.item: clockPill
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: false
        grabFocus: true
        color: "transparent"
        implicitWidth: 480
        implicitHeight: 355

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: "#313244"
            border.width: 1
            radius: 12

            CalendarView {
                anchors.fill: parent
                anchors.margins: 14
                visible: calendarPopup.visible
                onCloseRequested: calendarPopup.visible = false
            }
        }
    }
}
