import QtQuick
import Quickshell
import Quickshell.Io
import qs.components

Rectangle {
    id: nixPill
    color: "transparent"
    implicitWidth: 46
    implicitHeight: 32

    property string currentTab: "quick"
    property int currentBrightness: 100
    property bool isWifiOn: wifiStatusText.text.indexOf("ON") !== -1
    property bool isBtOn: btStatusText.text.indexOf("ON") !== -1

    property int updateCount: 0
    property bool isChecking: false
    property var tempUpdateList: []
    property int tempUpdateCount: 0

    ListModel {
        id: updateModel
    }

    function runCmd(proc, cmd) {
        proc.running = false
        proc.command = ["sh", "-c", cmd]
        proc.running = true
    }

    Text {
        anchors.centerIn: parent
        text: "" 
        color: "#74c7ec"
        font.pixelSize: 24
        font.family: "JetBrainsMono Nerd Font"
    }

    Rectangle {
        id: badge
        visible: nixPill.updateCount > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 0
        anchors.rightMargin: 0
        width: Math.max(18, badgeText.implicitWidth + 10)
        height: 18
        radius: 9
        color: "#eb4d4b"
        border.width: 0

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: nixPill.updateCount > 99 ? "99+" : nixPill.updateCount.toString()
            color: "#ffffff"
            font.pixelSize: 11
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            nixMenuPopup.visible = !nixMenuPopup.visible
        }
    }

    Process { id: setBrightnessProc }
    Process { id: wifiToggleProc }
    Process { id: wifiAppProc }
    Process { id: btToggleProc }
    Process { id: btAppProc }
    Process { id: manualCheckProc }

    function triggerManualCheck() {
        runCmd(manualCheckProc, "systemctl --user start nixos-update-check.service 2>/dev/null || (bash $HOME/nixconf/dotfiles/scripts/*update*.sh 2>/dev/null || bash $HOME/nixconf/dotfiles/scripts/*nixos*.sh 2>/dev/null; systemctl --user start nixos-update-check.service 2>/dev/null)")
        statusMonitorTimer.restart()
    }

    Process {
        id: checkStatusProc
        command: ["sh", "-c", "if [ \"$(systemctl --user show -p SubState --value nixos-update-check.service 2>/dev/null)\" = \"running\" ] || pgrep -x nvd >/dev/null; then echo 'RUNNING'; else echo 'STOPPED'; fi"]
        stdout: SplitParser {
            onRead: (data) => {
                let status = data.trim()
                if (status === "RUNNING") {
                    nixPill.isChecking = true
                } else {
                    if (nixPill.isChecking) {
                        nixPill.isChecking = false
                        updateReadProc.running = false
                        updateReadProc.running = true
                    }
                }
            }
        }
    }

    Timer {
        id: statusMonitorTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkStatusProc.running = false
            checkStatusProc.running = true
        }
    }

    Process {
        id: updateReadProc
        running: true
        command: ["sh", "-c", "[ -f /tmp/nixos-update-diff.txt ] && [ $(stat -c %Y /run/current-system 2>/dev/null || echo 0) -gt $(stat -c %Y /tmp/nixos-update-diff.txt 2>/dev/null || echo 0) ] && rm -f /tmp/nixos-update-diff.txt; [ -f /tmp/nixos-update-diff.txt ] && cat /tmp/nixos-update-diff.txt || echo ''"]
        stdout: SplitParser {
            onRead: (line) => {
                let trimmed = line.trim()
                if (trimmed !== "" && !trimmed.startsWith("<<") && !trimmed.startsWith(">>") && !trimmed.startsWith("Version changes:")) {
                    nixPill.tempUpdateList.push(trimmed)
                    if (trimmed.match(/^\[[^\]]+\]/) || trimmed.startsWith("+") || trimmed.startsWith("-")) {
                        nixPill.tempUpdateCount++
                    }
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                updateModel.clear()
                if (nixPill.tempUpdateList.length === 0) {
                    updateModel.append({ lineText: "󰄬 No package updates found. System is up to date!" })
                    nixPill.updateCount = 0
                } else {
                    for (let i = 0; i < nixPill.tempUpdateList.length; i++) {
                        updateModel.append({ lineText: nixPill.tempUpdateList[i] })
                    }
                    nixPill.updateCount = nixPill.tempUpdateCount
                }
                nixPill.tempUpdateList = []
                nixPill.tempUpdateCount = 0
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            updateReadProc.running = false
            updateReadProc.running = true
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: false
        onTriggered: {
            nixPill.triggerManualCheck()
        }
    }

    PopupWindow {
        id: nixMenuPopup
        anchor.item: nixPill
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: false
        grabFocus: true
        color: "transparent"
        implicitWidth: 640
        implicitHeight: 440

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: "#313244"
            border.width: 1
            radius: 12
            clip: true

            Rectangle {
                id: sidebar
                width: 150
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "#181825"

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6
                    Row {
                        spacing: 8
                        anchors.margins: 6
                        Text {
                            text: ""
                            color: "#74c7ec"
                            font.pixelSize: 18
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            text: "Settings"
                            color: "#cdd6f4"
                            font.pixelSize: 14
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Item {
                        width: parent.width
                        height: 6
                    }

                    Rectangle {
                        width: parent.width
                        height: 36
                        radius: 8
                        color: nixPill.currentTab === "quick" ? "#89b4fa" : (tab1Mouse.containsMouse ? "#2a2b3d" : "transparent")
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Text {
                                text: "󰒓"
                                color: nixPill.currentTab === "quick" ? "#1e1e2e" : "#89b4fa"
                                font.pixelSize: 15
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                text: "Quick"
                                color: nixPill.currentTab === "quick" ? "#1e1e2e" : "#cdd6f4"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        MouseArea {
                            id: tab1Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: nixPill.currentTab = "quick"
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 36
                        radius: 8
                        color: nixPill.currentTab === "nixos" ? "#89b4fa" : (tab2Mouse.containsMouse ? "#2a2b3d" : "transparent")
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Text {
                                text: "󰏔"
                                color: nixPill.currentTab === "nixos" ? "#1e1e2e" : "#f38ba8"
                                font.pixelSize: 15
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                text: "Updates"
                                color: nixPill.currentTab === "nixos" ? "#1e1e2e" : "#cdd6f4"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        Text {
                            visible: nixPill.isChecking
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰑐"
                            color: nixPill.currentTab === "nixos" ? "#1e1e2e" : "#a6e3a1"
                            font.pixelSize: 13
                            font.family: "JetBrainsMono Nerd Font"
                            transformOrigin: Item.Center
                            RotationAnimation on rotation {
                                running: nixPill.isChecking
                                loops: Animation.Infinite
                                from: 0
                                to: 360
                                duration: 1000
                            }
                        }

                        Rectangle {
                            visible: nixPill.updateCount > 0 && !nixPill.isChecking
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 18
                            height: 18
                            radius: 9
                            color: "#eb4d4b"
                            Text {
                                anchors.centerIn: parent
                                text: nixPill.updateCount > 9 ? "!" : nixPill.updateCount
                                color: "#ffffff"
                                font.pixelSize: 10
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        MouseArea {
                            id: tab2Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: nixPill.currentTab = "nixos"
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 36
                        radius: 8
                        color: nixPill.currentTab === "hardware" ? "#89b4fa" : (tab3Mouse.containsMouse ? "#2a2b3d" : "transparent")
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Text {
                                text: "󰍛"
                                color: nixPill.currentTab === "hardware" ? "#1e1e2e" : "#a6e3a1"
                                font.pixelSize: 15
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                text: "Hardware"
                                color: nixPill.currentTab === "hardware" ? "#1e1e2e" : "#cdd6f4"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        MouseArea {
                            id: tab3Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: nixPill.currentTab = "hardware"
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 36
                        radius: 8
                        color: nixPill.currentTab === "calendar" ? "#89b4fa" : (tab4Mouse.containsMouse ? "#2a2b3d" : "transparent")
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Text {
                                text: "󰃭"
                                color: nixPill.currentTab === "calendar" ? "#1e1e2e" : "#f9e2af"
                                font.pixelSize: 15
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                text: "Calendar"
                                color: nixPill.currentTab === "calendar" ? "#1e1e2e" : "#cdd6f4"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        MouseArea {
                            id: tab4Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: nixPill.currentTab = "calendar"
                        }
                    }
                }
            }

            Rectangle {
                anchors.left: sidebar.right
                width: 1
                height: parent.height
                color: "#313244"
            }

            Item {
                anchors.left: sidebar.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 18

                Column {
                    anchors.fill: parent
                    spacing: 14
                    visible: nixPill.currentTab === "quick"

                    Text {
                        text: "Quick Settings"
                        color: "#cdd6f4"
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#313244"
                    }

                    Column {
                        width: parent.width
                        spacing: 8
                        Row {
                            width: parent.width
                            Text {
                                text: "󰃠  Brightness"
                                color: "#f9e2af"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                anchors.right: parent.right
                                text: nixPill.currentBrightness + "%"
                                color: "#cdd6f4"
                                font.pixelSize: 13
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        Process {
                            running: true
                            command: ["sh", "-c", "while true; do brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'; sleep 1; done"]
                            stdout: SplitParser {
                                onRead: (data) => {
                                    let val = parseInt(data.trim())
                                    if (!isNaN(val)) nixPill.currentBrightness = val
                                }
                            }
                        }
                        Row {
                            width: parent.width
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            Text {
                                text: "󰃞"
                                color: "#f9e2af"
                                font.pixelSize: 15
                                font.family: "JetBrainsMono Nerd Font"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Item {
                                width: parent.width - 54
                                height: 24
                                anchors.verticalCenter: parent.verticalCenter
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width
                                    height: 8
                                    radius: 4
                                    color: "#2a2b3d"
                                    Rectangle {
                                        width: (nixPill.currentBrightness / 100) * parent.width
                                        height: parent.height
                                        radius: 4
                                        color: "#f9e2af"
                                    }
                                }
                                Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: sliderMouse.containsMouse || sliderMouse.pressed ? "#ffffff" : "#f9e2af"
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Math.max(0, Math.min(parent.width - width, ((nixPill.currentBrightness / 100) * parent.width) - (width / 2)))
                                    border.color: "#1e1e2e"
                                    border.width: 2
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰃠"
                                        color: "#1e1e2e"
                                        font.pixelSize: 10
                                        font.bold: true
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                                MouseArea {
                                    id: sliderMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    function updateBright(mouseX) {
                                        let pct = Math.max(1, Math.min(100, Math.round((Math.max(0, Math.min(width, mouseX)) / width) * 100)))
                                        nixPill.currentBrightness = pct
                                        nixPill.runCmd(setBrightnessProc, "brightnessctl set " + pct + "%")
                                    }
                                    onPressed: {
                                        updateBright(mouse.x)
                                    }
                                    onPositionChanged: {
                                        if (pressed) updateBright(mouse.x)
                                    }
                                }
                            }
                            Text {
                                text: "󰃠"
                                color: "#f9e2af"
                                font.pixelSize: 17
                                font.family: "JetBrainsMono Nerd Font"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#313244"
                    }

                    Column {
                        width: parent.width
                        spacing: 6
                        Row {
                            width: parent.width
                            Text {
                                text: "󰤨  Wi-Fi"
                                color: "#a6e3a1"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                id: wifiStatusText
                                anchors.right: parent.right
                                text: "OFF"
                                color: nixPill.isWifiOn ? "#a6e3a1" : "#f38ba8"
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        Process {
                            id: wifiCheckProc
                            running: true
                            command: ["sh", "-c", "while true; do if rfkill list wlan 2>/dev/null | grep -q 'Soft blocked: yes'; then echo 'OFF'; else SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2); if [ -n \"$SSID\" ]; then echo \"ON ($SSID)\"; else echo \"ON (Disconnected)\"; fi; fi; sleep 2; done"]
                            stdout: SplitParser {
                                onRead: (data) => {
                                    wifiStatusText.text = data.trim()
                                }
                            }
                        }
                        Row {
                            width: parent.width
                            spacing: 8
                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 32
                                radius: 6
                                color: nixPill.isWifiOn ? (wifiToggleMouse.containsMouse ? "#8ce187" : "#a6e3a1") : (wifiToggleMouse.containsMouse ? "#313244" : "#2a2b3d")
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "󰤨"
                                        color: nixPill.isWifiOn ? "#1e1e2e" : "#a6e3a1"
                                        font.pixelSize: 13
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                    Text {
                                        text: "Toggle"
                                        color: nixPill.isWifiOn ? "#1e1e2e" : "#cdd6f4"
                                        font.pixelSize: 12
                                        font.bold: nixPill.isWifiOn
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                                MouseArea {
                                    id: wifiToggleMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        nixPill.runCmd(wifiToggleProc, "rfkill toggle wlan || nmcli radio wifi toggle")
                                        wifiCheckProc.running = false
                                        wifiCheckProc.running = true
                                    }
                                }
                            }
                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 32
                                radius: 6
                                color: wifiAppMouse.containsMouse ? "#313244" : "#2a2b3d"
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "󰒓"
                                        color: "#89b4fa"
                                        font.pixelSize: 13
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                    Text {
                                        text: "Settings"
                                        color: "#cdd6f4"
                                        font.pixelSize: 12
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                                MouseArea {
                                    id: wifiAppMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        nixPill.runCmd(wifiAppProc, "nm-connection-editor || kitty -e nmtui")
                                        nixMenuPopup.visible = false
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#313244"
                    }

                    Column {
                        width: parent.width
                        spacing: 6
                        Row {
                            width: parent.width
                            Text {
                                text: "󰂯  Bluetooth"
                                color: "#89b4fa"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                id: btStatusText
                                anchors.right: parent.right
                                text: "OFF"
                                color: nixPill.isBtOn ? "#89b4fa" : "#f38ba8"
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                        Process {
                            id: btCheckProc
                            running: true
                            command: ["sh", "-c", "while true; do if rfkill list bluetooth 2>/dev/null | grep -q 'Soft blocked: yes' || ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then echo 'OFF'; else dev=$(bluetoothctl info 2>/dev/null | grep 'Name:' | cut -d: -f2 | xargs); [ -n \"$dev\" ] && echo \"ON ($dev)\" || echo \"ON (Disconnected)\"; fi; sleep 2; done"]
                            stdout: SplitParser {
                                onRead: (data) => {
                                    btStatusText.text = data.trim()
                                }
                            }
                        }
                        Row {
                            width: parent.width
                            spacing: 8
                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 32
                                radius: 6
                                color: nixPill.isBtOn ? (btToggleMouse.containsMouse ? "#b4befe" : "#89b4fa") : (btToggleMouse.containsMouse ? "#313244" : "#2a2b3d")
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "󰂯"
                                        color: nixPill.isBtOn ? "#1e1e2e" : "#89b4fa"
                                        font.pixelSize: 13
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                    Text {
                                        text: "Toggle"
                                        color: nixPill.isBtOn ? "#1e1e2e" : "#cdd6f4"
                                        font.pixelSize: 12
                                        font.bold: nixPill.isBtOn
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                                MouseArea {
                                    id: btToggleMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        nixPill.runCmd(btToggleProc, "rfkill toggle bluetooth || (bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on)")
                                        btCheckProc.running = false
                                        btCheckProc.running = true
                                    }
                                }
                            }
                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 32
                                radius: 6
                                color: btAppMouse.containsMouse ? "#313244" : "#2a2b3d"
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "󰒓"
                                        color: "#89b4fa"
                                        font.pixelSize: 13
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                    Text {
                                        text: "Settings"
                                        color: "#cdd6f4"
                                        font.pixelSize: 12
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                                MouseArea {
                                    id: btAppMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        nixPill.runCmd(btAppProc, "blueman-manager || kitty -e bluetoothctl")
                                        nixMenuPopup.visible = false
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#313244"
                    }

                    Row {
                        spacing: 8
                        width: parent.width
                        Rectangle {
                            width: (parent.width - 8) / 2
                            height: 32
                            radius: 6
                            color: btn1Mouse.containsMouse ? "#313244" : "#2a2b3d"
                            Row {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: "󰓃"
                                    color: "#a6e3a1"
                                    font.pixelSize: 13
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                Text {
                                    text: "Audio Mixer"
                                    color: "#cdd6f4"
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }
                            Process { id: audioProc; command: ["pavucontrol"] }
                            MouseArea {
                                id: btn1Mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    audioProc.running = true
                                    nixMenuPopup.visible = false
                                }
                            }
                        }
                        Rectangle {
                            width: (parent.width - 8) / 2
                            height: 32
                            radius: 6
                            color: btn2Mouse.containsMouse ? "#313244" : "#2a2b3d"
                            Row {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: "󰌾"
                                    color: "#f38ba8"
                                    font.pixelSize: 13
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                Text {
                                    text: "Lock Screen"
                                    color: "#cdd6f4"
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }
                            Process { id: lockProc; command: ["hyprlock"] }
                            MouseArea {
                                id: btn2Mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    lockProc.running = true
                                    nixMenuPopup.visible = false
                                }
                            }
                        }
                    }
                }

                Column {
                    anchors.fill: parent
                    spacing: 10
                    visible: nixPill.currentTab === "nixos"
                    Item {
                        width: parent.width
                        height: 28
                        Text {
                            text: "Pending Updates (" + nixPill.updateCount + ")"
                            color: "#cdd6f4"
                            font.pixelSize: 16
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: nixPill.isChecking ? 85 : 72
                            height: 26
                            radius: 6
                            color: checkBtnMouse.containsMouse ? "#313244" : "#2a2b3d"
                            Row {
                                anchors.centerIn: parent
                                spacing: 5
                                Text { 
                                    text: "󰑐"
                                    color: "#a6e3a1"
                                    font.pixelSize: 13
                                    font.family: "JetBrainsMono Nerd Font"
                                    transformOrigin: Item.Center
                                    RotationAnimation on rotation {
                                        running: nixPill.isChecking
                                        loops: Animation.Infinite
                                        from: 0
                                        to: 360
                                        duration: 1000
                                    }
                                }
                                Text {
                                    text: nixPill.isChecking ? "Checking" : "Check"
                                    color: "#cdd6f4"
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }
                            MouseArea {
                                id: checkBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: nixPill.triggerManualCheck()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: nixPill.isChecking ? 24 : 0
                        color: "#2a2b3d"
                        radius: 4
                        visible: nixPill.isChecking
                        clip: true

                        Behavior on height { NumberAnimation { duration: 150 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                text: "󰑐"
                                color: "#89b4fa"
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                                transformOrigin: Item.Center
                                RotationAnimation on rotation {
                                    running: nixPill.isChecking
                                    loops: Animation.Infinite
                                    from: 0
                                    to: 360
                                    duration: 1000
                                }
                            }
                            Text {
                                text: "Checking system updates in background..."
                                color: "#89b4fa"
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#313244"
                    }

                    Item {
                        width: parent.width
                        height: nixPill.isChecking ? 320 : 350
                        clip: true

                        ListView {
                            id: updateListView
                            anchors.fill: parent
                            anchors.rightMargin: 16
                            model: updateModel
                            spacing: 4
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            delegate: Rectangle {
                                width: updateListView.width
                                height: Math.max(22, itemText.implicitHeight + 4)
                                color: "transparent"

                                Text {
                                    id: itemText
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    text: lineText
                                    font.pixelSize: 11
                                    font.family: "JetBrainsMono Nerd Font"
                                    wrapMode: Text.Wrap
                                    color: {
                                        if (lineText.match(/^\[[A+]/) || lineText.startsWith("+")) return "#a6e3a1"
                                        if (lineText.match(/^\[[R\-D]/) || lineText.startsWith("-")) return "#f38ba8"
                                        if (lineText.match(/^\[[U~]/) || lineText.indexOf("->") !== -1) return "#89b4fa"
                                        return "#a6adc8"
                                    }
                                }
                            }
                        }

                        Item {
                            id: updateScrollbarArea
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 12
                            visible: updateListView.contentHeight > updateListView.height

                            Rectangle {
                                id: updateScrollTrack
                                anchors.centerIn: parent
                                width: 4
                                height: parent.height
                                radius: 2
                                color: "#2a2b3d"

                                Rectangle {
                                    id: updateScrollThumb
                                    width: parent.width
                                    radius: 2
                                    color: updateScrollMouse.containsMouse || updateScrollMouse.pressed ? "#b4befe" : "#89b4fa"
                                    y: updateListView.visibleArea.yPosition * updateScrollTrack.height
                                    height: Math.max(20, updateListView.visibleArea.heightRatio * updateScrollTrack.height)
                                }
                            }

                            MouseArea {
                                id: updateScrollMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                function scrollToMouse(mouseY) {
                                    let maxContentY = updateListView.contentHeight - updateListView.height
                                    if (maxContentY <= 0) return
                                    let thumbHeight = updateScrollThumb.height
                                    let availableTrack = updateScrollTrack.height - thumbHeight
                                    if (availableTrack <= 0) return
                                    let clickY = mouseY - (thumbHeight / 2)
                                    let clampedY = Math.max(0, Math.min(availableTrack, clickY))
                                    updateListView.contentY = (clampedY / availableTrack) * maxContentY
                                }

                                onPressed: (mouse) => scrollToMouse(mouse.y)
                                onPositionChanged: (mouse) => { if (pressed) scrollToMouse(mouse.y) }
                            }
                        }
                    }
                }

                ProcessView {
                    anchors.fill: parent
                    visible: nixPill.currentTab === "hardware"
                }

                CalendarView {
                    anchors.fill: parent
                    visible: nixPill.currentTab === "calendar"
                    onCloseRequested: nixMenuPopup.visible = false
                }
            }
        }
    }
}
