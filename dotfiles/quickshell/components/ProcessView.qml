import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: procRoot

    property string sortBy: "cpu"
    property var tempProcessList: []

    ListModel { id: processModel }

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
                    procRoot.tempProcessList.push({
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
        procRoot.tempProcessList = []
        let sortFlag = procRoot.sortBy === "cpu" ? "-%cpu" : "-rss"
        fetchPsProc.command = ["sh", "-c", "ps -eo pid,%cpu,rss,comm --sort=" + sortFlag + " | tail -n +2 | head -n 30"]
        fetchPsProc.running = true
    }

    Timer {
        id: refreshTimer
        interval: 2000
        running: procRoot.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: procRoot.updateProcesses()
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Item {
            width: parent.width; height: 28
            Row {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 8
                Text { text: "󰍛"; color: "#89b4fa"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
                Text { text: "Process Manager"; color: "#cdd6f4"; font.pixelSize: 15; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
            }
            Row {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                Rectangle {
                    width: 58; height: 26; radius: 6; color: procRoot.sortBy === "cpu" ? "#94e2d5" : "#2a2b3d"
                    Text { anchors.centerIn: parent; text: "CPU %"; color: procRoot.sortBy === "cpu" ? "#1e1e2e" : "#cdd6f4"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { procRoot.sortBy = "cpu"; procRoot.updateProcesses() } }
                }
                Rectangle {
                    width: 58; height: 26; radius: 6; color: procRoot.sortBy === "mem" ? "#cba6f7" : "#2a2b3d"
                    Text { anchors.centerIn: parent; text: "RAM"; color: procRoot.sortBy === "mem" ? "#1e1e2e" : "#cdd6f4"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { procRoot.sortBy = "mem"; procRoot.updateProcesses() } }
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: "#313244" }

        Row {
            width: parent.width; spacing: 4
            Text { width: 55; text: "PID"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
            Text { width: 180; text: "PROCESS"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
            Text { width: 55; text: "CPU%"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"; horizontalAlignment: Text.AlignRight }
            Text { width: 55; text: "RAM"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"; horizontalAlignment: Text.AlignRight }
            Text { width: 35; text: "KILL"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"; horizontalAlignment: Text.AlignHCenter }
        }

        Item {
            width: parent.width; height: parent.height - 70; clip: true
            ListView {
                id: procListView; anchors.fill: parent; anchors.rightMargin: 16; model: processModel; spacing: 4; clip: true
                delegate: Rectangle {
                    width: procListView.width; height: 26; radius: 6; color: rowMouse.containsMouse ? "#2a2b3d" : "transparent"
                    MouseArea { id: rowMouse; anchors.fill: parent; hoverEnabled: true }
                    Row {
                        anchors.fill: parent; anchors.margins: 4; spacing: 4
                        Text { width: 55; anchors.verticalCenter: parent.verticalCenter; text: pid; color: "#89b4fa"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                        Text { width: 176; anchors.verticalCenter: parent.verticalCenter; text: name; color: "#cdd6f4"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; elide: Text.ElideRight }
                        Text { width: 55; anchors.verticalCenter: parent.verticalCenter; text: cpu + "%"; color: "#94e2d5"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; horizontalAlignment: Text.AlignRight }
                        Text { width: 55; anchors.verticalCenter: parent.verticalCenter; text: mem; color: "#cba6f7"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; horizontalAlignment: Text.AlignRight }
                        Item {
                            width: 35; height: parent.height; anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                anchors.centerIn: parent; width: 20; height: 20; radius: 4; color: killBtnMouse.containsMouse ? "#f38ba8" : "#313244"
                                Text { anchors.centerIn: parent; text: "󰅖"; color: killBtnMouse.containsMouse ? "#1e1e2e" : "#f38ba8"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                                MouseArea { id: killBtnMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: procRoot.killProcess(pid) }
                            }
                        }
                    }
                }
            }
            Item {
                anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 12; visible: procListView.contentHeight > procListView.height
                Rectangle {
                    id: scrollTrack; anchors.centerIn: parent; width: 4; height: parent.height; radius: 2; color: "#2a2b3d"
                    Rectangle { id: scrollThumb; width: parent.width; radius: 2; color: scrollMouse.containsMouse || scrollMouse.pressed ? "#b4befe" : "#89b4fa"; y: procListView.visibleArea.yPosition * scrollTrack.height; height: Math.max(20, procListView.visibleArea.heightRatio * scrollTrack.height) }
                }
                MouseArea {
                    id: scrollMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    function scrollToMouse(mouseY) {
                        let maxH = procListView.contentHeight - procListView.height; if (maxH <= 0) return
                        let availH = scrollTrack.height - scrollThumb.height; if (availH <= 0) return
                        procListView.contentY = (Math.max(0, Math.min(availH, mouseY - (scrollThumb.height / 2))) / availH) * maxH
                    }
                    onPressed: (mouse) => scrollToMouse(mouse.y); onPositionChanged: (mouse) => { if (pressed) scrollToMouse(mouse.y) }
                }
            }
        }
    }
}
