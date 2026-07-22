import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: hardwarePill
    color: "#99313244"
    radius: 8
    implicitWidth: hardwareRow.implicitWidth + 24
    implicitHeight: 32

    property string sortBy: "cpu"

    property var tempProcessList: []

    ListModel {
        id: processModel
    }

    // ==========================================
    // 1. TOP BAR METRICS (Original Modules)
    // ==========================================
    Row {
        id: hardwareRow
        anchors.centerIn: parent
        spacing: 15

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Process {
                running: true
                command: ["sh", "-c", "while true; do vmstat 1 2 | tail -1 | awk '{print 100 - $15\"%\"}'; sleep 2; done"]
                stdout: SplitParser {
                    onRead: (data) => cpuText.text = data.trim()
                }
            }
            Text {
                text: ""
                color: "#94e2d5"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: cpuText
                text: "..."
                color: "#94e2d5"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Process {
                running: true
                command: ["sh", "-c", "while true; do cat $(grep -lE 'k10temp|zenpower' /sys/class/hwmon/hwmon*/name 2>/dev/null | sed 's/name/temp3_input/') 2>/dev/null | head -n 1 | awk '{print int($1/1000)\"°C\"}' || echo '?°C'; sleep 5; done"]
                stdout: SplitParser {
                    onRead: (data) => tempText.text = data.trim()
                }
            }
            Text {
                text: ""
                color: "#fab387"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: tempText
                text: "..."
                color: "#fab387"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Process {
                running: true
                command: ["sh", "-c", "while true; do free -h | awk '/^Mem:/ {print $3}' | sed 's/i//g'; sleep 2; done"]
                stdout: SplitParser {
                    onRead: (data) => memText.text = data.trim()
                }
            }
            Text {
                text: ""
                color: "#cba6f7"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                id: memText
                text: "..."
                color: "#cba6f7"
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: hwPopup.visible = !hwPopup.visible
    }

    // ==========================================
    // 2. PROCESS FETCHING & KILL LOGIC
    // ==========================================
    Process { id: killProc }

    function killProcess(pid) {
        killProc.running = false
        killProc.command = ["kill", "-9", pid]
        killProc.running = true
        refreshTimer.restart()
    }

    Process {
        id: fetchPsProc
        stdout: SplitParser {
            onRead: (line) => {
                let parts = line.trim().split(/\s+/)
                if (parts.length >= 4) {
                    let rssKB = parseInt(parts[2]) || 0
                    let memMB = Math.round(rssKB / 1024) + "M"
                    hardwarePill.tempProcessList.push({
                        pid: parts[0],
                        cpu: parts[1],
                        mem: memMB,
                        name: parts.slice(3).join(" ")
                    })
                }
            }
        }
        onRunningChanged: {
            if (!running && tempProcessList.length > 0) {
                for (let i = 0; i < tempProcessList.length; i++) {
                    let item = tempProcessList[i]
                    if (i < processModel.count) {
                        processModel.set(i, item)
                    } else {
                        processModel.append(item)
                    }
                }

                while (processModel.count > tempProcessList.length) {
                    processModel.remove(processModel.count - 1)
                }

                tempProcessList = []
            }
        }
    }

    function updateProcesses() {
        fetchPsProc.running = false
        hardwarePill.tempProcessList = []
        let sortFlag = hardwarePill.sortBy === "cpu" ? "-%cpu" : "-rss"
        fetchPsProc.command = ["sh", "-c", "ps -eo pid,%cpu,rss,comm --sort=" + sortFlag + " | tail -n +2 | head -n 30"]
        fetchPsProc.running = true
    }

    Timer {
        id: refreshTimer
        interval: 2000
        running: hwPopup.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: hardwarePill.updateProcesses()
    }

    // ==========================================
    // 3. SCROLLABLE POPUP PROCESS MANAGER
    // ==========================================
    PopupWindow {
        id: hwPopup
        anchor.item: hardwarePill
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: false
        grabFocus: true
        color: "transparent"

        implicitWidth: 380
        implicitHeight: 380

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: "#313244"
            border.width: 1
            radius: 12

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Item {
                    width: parent.width
                    height: 28

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Text {
                            text: "󰍛"
                            color: "#89b4fa"
                            font.pixelSize: 18
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            text: "Process Manager"
                            color: "#cdd6f4"
                            font.pixelSize: 15
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Rectangle {
                            width: 58
                            height: 26
                            radius: 6
                            color: hardwarePill.sortBy === "cpu" ? "#94e2d5" : "#2a2b3d"
                            Text {
                                anchors.centerIn: parent
                                text: "CPU %"
                                color: hardwarePill.sortBy === "cpu" ? "#1e1e2e" : "#cdd6f4"
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    hardwarePill.sortBy = "cpu"
                                    hardwarePill.updateProcesses()
                                }
                            }
                        }

                        Rectangle {
                            width: 58
                            height: 26
                            radius: 6
                            color: hardwarePill.sortBy === "mem" ? "#cba6f7" : "#2a2b3d"
                            Text {
                                anchors.centerIn: parent
                                text: "RAM"
                                color: hardwarePill.sortBy === "mem" ? "#1e1e2e" : "#cdd6f4"
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    hardwarePill.sortBy = "mem"
                                    hardwarePill.updateProcesses()
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#313244" }

                Row {
                    width: parent.width
                    spacing: 4

                    Text { width: 55; text: "PID"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    Text { width: 135; text: "PROCESS"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    Text { width: 50; text: "CPU%"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"; horizontalAlignment: Text.AlignRight }
                    Text { width: 50; text: "RAM"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"; horizontalAlignment: Text.AlignRight }
                    Text { width: 35; text: "KILL"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"; horizontalAlignment: Text.AlignHCenter }
                }

                Item {
                    width: parent.width
                    height: 280
                    clip: true

                    ListView {
                        id: procListView
                        anchors.fill: parent
                        anchors.rightMargin: 16
                        model: processModel
                        spacing: 4
                        clip: true

                        delegate: Rectangle {
                            width: procListView.width
                            height: 28
                            radius: 6
                            color: rowMouse.containsMouse ? "#2a2b3d" : "transparent"

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 4

                                Text {
                                    width: 55
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: pid
                                    color: "#89b4fa"
                                    font.pixelSize: 11
                                    font.family: "JetBrainsMono Nerd Font"
                                }

                                Text {
                                    width: 131
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: name
                                    color: "#cdd6f4"
                                    font.pixelSize: 11
                                    font.family: "JetBrainsMono Nerd Font"
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: 50
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: cpu + "%"
                                    color: "#94e2d5"
                                    font.pixelSize: 11
                                    font.family: "JetBrainsMono Nerd Font"
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    width: 50
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: mem
                                    color: "#cba6f7"
                                    font.pixelSize: 11
                                    font.family: "JetBrainsMono Nerd Font"
                                    horizontalAlignment: Text.AlignRight
                                }

                                Item {
                                    width: 35
                                    height: parent.height
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        radius: 4
                                        color: killBtnMouse.containsMouse ? "#f38ba8" : "#313244"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰅖"
                                            color: killBtnMouse.containsMouse ? "#1e1e2e" : "#f38ba8"
                                            font.pixelSize: 12
                                            font.family: "JetBrainsMono Nerd Font"
                                        }

                                        MouseArea {
                                            id: killBtnMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: hardwarePill.killProcess(pid)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        id: scrollbarArea
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 12 // Comfortable hit area for mouse interaction
                        visible: procListView.contentHeight > procListView.height

                        Rectangle {
                            id: scrollTrack
                            anchors.centerIn: parent
                            width: 4
                            height: parent.height
                            radius: 2
                            color: "#2a2b3d"

                            // Visual Thumb
                            Rectangle {
                                id: scrollThumb
                                width: parent.width
                                radius: 2
                                color: scrollMouse.containsMouse || scrollMouse.pressed ? "#b4befe" : "#89b4fa"
                                y: procListView.visibleArea.yPosition * scrollTrack.height
                                height: Math.max(20, procListView.visibleArea.heightRatio * scrollTrack.height)
                            }
                        }

                        // Drag & Click Handler
                        MouseArea {
                            id: scrollMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            function scrollToMouse(mouseY) {
                                let maxContentY = procListView.contentHeight - procListView.height
                                if (maxContentY <= 0) return

                                let thumbHeight = scrollThumb.height
                                let availableTrack = scrollTrack.height - thumbHeight
                                if (availableTrack <= 0) return

                                let clickY = mouseY - (thumbHeight / 2)
                                let clampedY = Math.max(0, Math.min(availableTrack, clickY))
                                procListView.contentY = (clampedY / availableTrack) * maxContentY
                            }

                            onPressed: (mouse) => scrollToMouse(mouse.y)
                            onPositionChanged: (mouse) => {
                                if (pressed) scrollToMouse(mouse.y)
                            }
                        }
                    }
                }
            }
        }
    }
}

