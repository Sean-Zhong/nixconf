import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Rectangle {
    id: volumePill
    color: "#99313244"
    radius: 16

    implicitWidth: volRow.implicitWidth + 24
    implicitHeight: 32

    property var sink: Pipewire.defaultAudioSink

    Process {
        id: swayncProc
        command: ["swaync-client", "-t", "-sw"]
    }

    PwObjectTracker {
        objects: volumePill.sink ? [volumePill.sink] : []
    }

    Row {
        id: volRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                let audio = volumePill.sink?.audio
                if (!audio || audio.muted) return "󰝟"
                if (audio.volume > 0.66) return "󰕾"
                if (audio.volume > 0.33) return "󰖀"
                return "󰕿"
            }
            color: "#ffffff"
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                let audio = volumePill.sink?.audio
                if (!audio) return "0%"
                return Math.round(audio.volume * 100) + "%"
            }
            color: "#ffffff"
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onWheel: (wheel) => {
            let audio = volumePill.sink?.audio
            if (!audio) return;
            if (wheel.angleDelta.y > 0) {
                audio.volume = Math.min(1.0, audio.volume + 0.05)
            } else {
                audio.volume = Math.max(0.0, audio.volume - 0.05)
            }
        }
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                let audio = volumePill.sink?.audio
                if (audio) audio.muted = !audio.muted
            } else {
                swayncProc.running = true
            }
        }
    }
}
