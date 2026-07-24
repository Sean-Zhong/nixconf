import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: processRoot

    property real cpuVal: 0
    property real ramVal: 0
    property real ramUsedGb: 0
    property real ramTotalGb: 0
    property real cpuTemp: 0

    property real peakCpuVal: 0
    property real peakCpuTemp: 0
    property real peakRamVal: 0
    property real peakRamUsedGb: 0

    property string sortBy: "cpu"
    property bool sortAscending: false
    property string sortFlag: "-%cpu"

    property var cpuHistory: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    property var ramHistory: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    function resetPeaks() {
        processRoot.peakCpuVal = processRoot.cpuVal
        processRoot.peakCpuTemp = processRoot.cpuTemp
        processRoot.peakRamVal = processRoot.ramVal
        processRoot.peakRamUsedGb = processRoot.ramUsedGb
    }

    function changeSort(field) {
        if (processRoot.sortBy === field) {
            processRoot.sortAscending = !processRoot.sortAscending
        } else {
            processRoot.sortBy = field
            processRoot.sortAscending = false
        }
        processRoot.sortFlag = (field === "cpu" ? "-%cpu" : "-rss")
        procListProc.running = false
        procListProc.command = ["sh", "-c", "while true; do ps -eo pid,%cpu,rss,comm --sort=" + processRoot.sortFlag + " | head -n 15 | awk 'NR>1 {pid=$1; cpu=$2; rss=sprintf(\"%.1f MB\", $3/1024); $1=$2=$3=\"\"; sub(/^ +/, \"\"); print pid \"|\" $0 \"|\" cpu \"|\" rss}' | tr '\\n' ';'; echo \"\"; sleep 3; done"]
        procListProc.running = true
    }

    function updateMetrics(cpu, ramP, ramU, ramT, temp) {
        processRoot.cpuVal = Math.round(cpu)
        processRoot.ramVal = Math.round(ramP)
        processRoot.ramUsedGb = parseFloat(ramU.toFixed(1))
        processRoot.ramTotalGb = parseFloat(ramT.toFixed(1))
        processRoot.cpuTemp = Math.round(temp)

        if (processRoot.cpuVal > processRoot.peakCpuVal) processRoot.peakCpuVal = processRoot.cpuVal
        if (processRoot.cpuTemp > processRoot.peakCpuTemp) processRoot.peakCpuTemp = processRoot.cpuTemp
        if (processRoot.ramUsedGb > processRoot.peakRamUsedGb) {
            processRoot.peakRamUsedGb = processRoot.ramUsedGb
            processRoot.peakRamVal = processRoot.ramVal
        }

        let cHist = processRoot.cpuHistory.slice(1)
        cHist.push(processRoot.cpuVal)
        processRoot.cpuHistory = cHist

        let rHist = processRoot.ramHistory.slice(1)
        rHist.push(processRoot.ramVal)
        processRoot.ramHistory = rHist

        cpuCanvas.requestPaint()
        ramCanvas.requestPaint()
    }

    Process {
        id: sysMonProc
        running: true
        command: ["sh", "-c", "prev_idle=0; prev_total=0; while true; do read -r line < /proc/stat; set -- $line; idle=$5; total=$(($2+$3+$4+$5+$6+$7+$8)); diff_idle=$((idle - prev_idle)); diff_total=$((total - prev_total)); cpu=0; [ $diff_total -ne 0 ] && cpu=$(( 100 * (diff_total - diff_idle) / diff_total )); prev_idle=$idle; prev_total=$total; ram_info=$(free -m | awk '/Mem:/ {printf \"%.1f|%.2f|%.2f\", $3/$2*100, $3/1024, $2/1024}'); hw=$(grep -lE 'k10temp|zenpower|coretemp' /sys/class/hwmon/hwmon*/name 2>/dev/null | head -n 1 | sed 's|/name||'); temp=\"\"; if [ -n \"$hw\" ]; then lbl=$(grep -lE 'Tccd1|Tdie' \"$hw\"/temp*_label 2>/dev/null | head -n 1); [ -n \"$lbl\" ] && temp=$(cat \"${lbl%label}input\" 2>/dev/null); [ -z \"$temp\" ] && temp=$(cat \"$hw\"/temp1_input 2>/dev/null); fi; [ -z \"$temp\" ] && temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1); [ -n \"$temp\" ] && [ \"$temp\" -gt 0 ] && temp=$((temp / 1000)) || temp=0; echo \"$cpu|$ram_info|$temp\"; sleep 2; done"]
        stdout: SplitParser {
            onRead: (data) => {
                let parts = data.trim().split("|")
                if (parts.length >= 5) {
                    let cpu = parseFloat(parts[0]) || 0
                    let ramPct = parseFloat(parts[1]) || 0
                    let ramU = parseFloat(parts[2]) || 0
                    let ramT = parseFloat(parts[3]) || 0
                    let temp = parseFloat(parts[4]) || 0
                    processRoot.updateMetrics(cpu, ramPct, ramU, ramT, temp)
                }
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Row {
            width: parent.width
            height: 160
            spacing: 12

            Rectangle {
                width: (parent.width - 12) / 2
                height: parent.height
                color: "#2a2b3d"
                radius: 10
                clip: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Item {
                        width: parent.width; height: 18
                        Text {
                            anchors.left: parent.left
                            text: "󰍛 CPU"
                            color: "#89b4fa"
                            font.pixelSize: 14; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.right: parent.right
                            text: processRoot.cpuVal + "%"
                            color: "#ffffff"
                            font.pixelSize: 15; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Item {
                        width: parent.width; height: 14
                        Text {
                            anchors.left: parent.left
                            text: "󰏈 Temp: " + processRoot.cpuTemp + "°C"
                            color: processRoot.cpuTemp > 75 ? "#f38ba8" : "#f9e2af"
                            font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.right: parent.right
                            text: "Max: " + processRoot.peakCpuTemp + "°C"
                            color: "#a6adc8"
                            font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Item {
                        width: parent.width; height: 14
                        Text {
                            anchors.left: parent.left
                            text: "Peak Usage: " + processRoot.peakCpuVal + "%"
                            color: "#f38ba8"
                            font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Item { width: parent.width; height: 2 }

                    Canvas {
                        id: cpuCanvas
                        width: parent.width; height: 66
                        onPaint: {
                            let ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            let hist = processRoot.cpuHistory
                            if (hist.length < 2) return
                            ctx.beginPath(); ctx.moveTo(0, height)
                            for (let i = 0; i < hist.length; i++) {
                                let x = (i / (hist.length - 1)) * width
                                let y = height - (hist[i] / 100) * height
                                ctx.lineTo(x, y)
                            }
                            ctx.lineTo(width, height); ctx.closePath()
                            ctx.fillStyle = "rgba(137, 180, 250, 0.25)"; ctx.fill()
                            ctx.beginPath()
                            for (let j = 0; j < hist.length; j++) {
                                let lx = (j / (hist.length - 1)) * width
                                let ly = height - (hist[j] / 100) * height
                                if (j === 0) ctx.moveTo(lx, ly); else ctx.lineTo(lx, ly)
                            }
                            ctx.strokeStyle = "#89b4fa"; ctx.lineWidth = 2; ctx.stroke()
                        }
                    }
                }
            }

            Rectangle {
                width: (parent.width - 12) / 2
                height: parent.height
                color: "#2a2b3d"
                radius: 10
                clip: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Item {
                        width: parent.width; height: 18
                        Text {
                            anchors.left: parent.left
                            text: "󰘚 RAM"
                            color: "#a6e3a1"
                            font.pixelSize: 14; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.right: parent.right
                            text: processRoot.ramVal + "%"
                            color: "#ffffff"
                            font.pixelSize: 15; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Item {
                        width: parent.width; height: 14
                        Text {
                            anchors.left: parent.left
                            text: "Used: " + processRoot.ramUsedGb + " GB"
                            color: "#cdd6f4"
                            font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.right: parent.right
                            text: "Total: " + processRoot.ramTotalGb + " GB"
                            color: "#a6adc8"
                            font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Item {
                        width: parent.width; height: 14
                        Text {
                            anchors.left: parent.left
                            text: "Peak: " + processRoot.peakRamVal + "% (" + processRoot.peakRamUsedGb + " GB)"
                            color: "#f38ba8"
                            font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Item { width: parent.width; height: 2 }

                    Canvas {
                        id: ramCanvas
                        width: parent.width; height: 66
                        onPaint: {
                            let ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            let hist = processRoot.ramHistory
                            if (hist.length < 2) return
                            ctx.beginPath(); ctx.moveTo(0, height)
                            for (let i = 0; i < hist.length; i++) {
                                let x = (i / (hist.length - 1)) * width
                                let y = height - (hist[i] / 100) * height
                                ctx.lineTo(x, y)
                            }
                            ctx.lineTo(width, height); ctx.closePath()
                            ctx.fillStyle = "rgba(166, 227, 161, 0.25)"; ctx.fill()
                            ctx.beginPath()
                            for (let j = 0; j < hist.length; j++) {
                                let lx = (j / (hist.length - 1)) * width
                                let ly = height - (hist[j] / 100) * height
                                if (j === 0) ctx.moveTo(lx, ly); else ctx.lineTo(lx, ly)
                            }
                            ctx.strokeStyle = "#a6e3a1"; ctx.lineWidth = 2; ctx.stroke()
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: 22

            Text {
                text: "Active Processes"
                color: "#cdd6f4"
                font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 90; height: 22; radius: 5
                color: resetMouse.containsMouse ? "#313244" : "#2a2b3d"

                Row {
                    anchors.centerIn: parent; spacing: 4
                    Text { text: "󰑐"; color: "#f38ba8"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                    Text { text: "Reset Peaks"; color: "#cdd6f4"; font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                }
                MouseArea {
                    id: resetMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: processRoot.resetPeaks()
                }
            }
        }

        Rectangle {
            width: parent.width - 16
            height: 24
            color: "#181825"
            radius: 6

            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    width: parent.width - 286
                    text: "NAME"
                    color: "#a6adc8"
                    font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    width: 45
                    text: "PID"
                    color: "#a6adc8"
                    font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 60; height: parent.height; color: "transparent"
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        Text {
                            text: "CPU %"
                            color: processRoot.sortBy === "cpu" ? "#89b4fa" : "#a6adc8"
                            font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            text: processRoot.sortBy === "cpu" ? (processRoot.sortAscending ? "▲" : "▼") : ""
                            color: "#89b4fa"
                            font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: processRoot.changeSort("cpu")
                    }
                }

                Rectangle {
                    width: 80; height: parent.height; color: "transparent" // Exact match to Delegate RAM!
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        Text {
                            text: "RAM (MB)"
                            color: processRoot.sortBy === "mem" ? "#a6e3a1" : "#a6adc8"
                            font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            text: processRoot.sortBy === "mem" ? (processRoot.sortAscending ? "▲" : "▼") : ""
                            color: "#a6e3a1"
                            font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: processRoot.changeSort("mem")
                    }
                }

                Text {
                    width: 45
                    horizontalAlignment: Text.AlignHCenter
                    text: "ACTION"
                    color: "#a6adc8"
                    font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Item {
            width: parent.width
            height: Math.max(100, parent.height - 236)
            clip: true

            ListModel { id: procModel }

            Process {
                id: procListProc
                running: true
                command: ["sh", "-c", "while true; do ps -eo pid,%cpu,rss,comm --sort=" + processRoot.sortFlag + " | head -n 15 | awk 'NR>1 {pid=$1; cpu=$2; rss=sprintf(\"%.1f MB\", $3/1024); $1=$2=$3=\"\"; sub(/^ +/, \"\"); print pid \"|\" $0 \"|\" cpu \"|\" rss}' | tr '\\n' ';'; echo \"\"; sleep 3; done"]
                stdout: SplitParser {
                    onRead: (data) => {
                        let raw = data.trim()
                        if (raw === "") return
                        let procs = raw.split(";")
                        let tempItems = []

                        for (let i = 0; i < procs.length; i++) {
                            let entry = procs[i].trim()
                            if (entry === "") continue
                            let parts = entry.split('|')
                            if (parts.length >= 4) {
                                tempItems.push({
                                    pPid: parts[0],
                                    pName: parts[1],
                                    pCpu: parts[2] + "%",
                                    pMem: parts[3]
                                })
                            }
                        }

                        if (tempItems.length > 0) {
                            if (processRoot.sortAscending) {
                                tempItems.reverse()
                            }

                            if (procModel.count === tempItems.length) {
                                for (let j = 0; j < tempItems.length; j++) {
                                    procModel.set(j, tempItems[j])
                                }
                            } else {
                                procModel.clear()
                                for (let j = 0; j < tempItems.length; j++) {
                                    procModel.append(tempItems[j])
                                }
                            }
                        }
                    }
                }
            }

            ListView {
                id: procListView
                anchors.fill: parent
                anchors.rightMargin: 16
                model: procModel
                spacing: 4
                clip: true
                interactive: true
                boundsBehavior: Flickable.StopAtBounds

                WheelHandler {
                    onWheel: (event) => {
                        let maxContentY = Math.max(0, procListView.contentHeight - procListView.height)
                        procListView.contentY = Math.max(0, Math.min(maxContentY, procListView.contentY - event.angleDelta.y))
                    }
                }

                delegate: Rectangle {
                    width: procListView.width
                    height: 28
                    radius: 6
                    color: itemMouse.containsMouse ? "#313244" : "#2a2b3d"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            width: parent.width - 286
                            text: pName
                            color: "#cdd6f4"
                            font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            width: 45
                            text: pPid
                            color: "#a6adc8"
                            font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            width: 60
                            text: pCpu
                            color: "#89b4fa"
                            font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            width: 80
                            text: pMem
                            color: "#a6e3a1"
                            font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: 45
                            height: 20
                            anchors.verticalCenter: parent.verticalCenter

                            Process { id: killProc }

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: killMouse.containsMouse ? "#eb4d4b" : "#313244"

                                Text {
                                    anchors.centerIn: parent
                                    text: "Kill"
                                    color: killMouse.containsMouse ? "#ffffff" : "#f38ba8"
                                    font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                                }

                                MouseArea {
                                    id: killMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        killProc.command = ["kill", "-9", pPid]
                                        killProc.running = true
                                    }
                                }
                            }
                        }
                    }

                    MouseArea { id: itemMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                }
            }

            Item {
                id: procScrollbarArea
                anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 12
                visible: procListView.contentHeight > procListView.height

                Rectangle {
                    id: procScrollTrack
                    anchors.centerIn: parent; width: 4; height: parent.height; radius: 2; color: "#2a2b3d"

                    Rectangle {
                        id: procScrollThumb
                        width: parent.width; radius: 2
                        color: procScrollMouse.containsMouse || procScrollMouse.pressed ? "#b4befe" : "#89b4fa"
                        y: procListView.visibleArea.yPosition * procScrollTrack.height
                        height: Math.max(20, procListView.visibleArea.heightRatio * procScrollTrack.height)
                    }
                }

                MouseArea {
                    id: procScrollMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    function scrollToMouse(mouseY) {
                        let maxContentY = procListView.contentHeight - procListView.height
                        if (maxContentY <= 0) return
                        let thumbHeight = procScrollThumb.height
                        let availableTrack = procScrollTrack.height - thumbHeight
                        if (availableTrack <= 0) return
                        let clickY = mouseY - (thumbHeight / 2)
                        let clampedY = Math.max(0, Math.min(availableTrack, clickY))
                        procListView.contentY = (clampedY / availableTrack) * maxContentY
                    }
                    onPressed: (mouse) => scrollToMouse(mouse.y)
                    onPositionChanged: (mouse) => { if (pressed) scrollToMouse(mouse.y) }
                }
            }
        }
    }
}
