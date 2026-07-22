import QtQuick
import QtQml

Row {
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: timeText.text = Qt.formatDateTime(new Date(), "HH:mm MM-dd")
    }

    Text {
        id: timeText
        text: Qt.formatDateTime(new Date(), "HH:mm    MM-dd")
        color: "#ffffff"
        font.pixelSize: 16
        font.family: "JetBrainsMono Nerd Font"
        font.bold: true
    }
}
