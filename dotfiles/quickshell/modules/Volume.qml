import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Rectangle {
    id: volumePill
    color: "#99313244"
    radius: 8

    implicitWidth: volRow.implicitWidth + 24
    implicitHeight: 32

    property var sink: Pipewire.defaultAudioSink
    property var barHeights: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    Process {
        id: swayncProc
        command: ["swaync-client", "-t", "-sw"]
    }

    Process {
        id: cavaProc
        running: true
        command: ["sh", "-c", "stdbuf -oL cava -p ~/.config/cava/quickshell.conf"]
        onRunningChanged: {
            if (!running) {
                cavaRestartTimer.start()
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                let values = data.trim().split(";").map(v => parseInt(v) || 0)
                if (values.length >= 16) {
                    volumePill.barHeights = values.slice(0, 16)
                }
            }
        }
    }

    Timer {
        id: cavaRestartTimer
        interval: 1000
        repeat: false
        onTriggered: cavaProc.running = true
    }

    PwObjectTracker {
        objects: volumePill.sink ? [volumePill.sink] : []
    }

    Row {
        id: volRow
        anchors.centerIn: parent
        spacing: 10

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            visible: volumePill.sink?.audio && !volumePill.sink.audio.muted

            Repeater {
                model: volumePill.barHeights
                delegate: Rectangle {
                    required property var modelData
                    width: 3
                    height: Math.max(3, Math.min(16, (modelData / 10) * 16))
                    radius: 1.5
                    color: "#89b4fa" // Catppuccin Blue
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on height {
                        NumberAnimation { duration: 50 }
                    }
                }
            }
        }

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
            font.bold: true
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
