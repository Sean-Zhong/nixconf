import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: calRoot

    property var now: new Date()
    signal closeRequested()

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: calRoot.now = new Date()
    }

    onVisibleChanged: {
        if (visible) calCard.displayDate = new Date()
    }

    Process {
        id: openGCalProc
        command: ["xdg-open", "https://calendar.google.com"]
    }

    Column {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            id: topClockBox
            width: parent.width
            height: 76
            color: "#2a2b3d"
            radius: 10

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(calRoot.now, "HH:mm:ss")
                    color: "#ffffff"
                    font.pixelSize: 30
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(calRoot.now, "dddd, MMMM d")
                    color: "#89b4fa"
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }

        Row {
            width: parent.width
            height: parent.height - topClockBox.height - 12
            spacing: 12

            Rectangle {
                id: weatherCard
                width: 170; height: parent.height; color: "#2a2b3d"; radius: 10
                property string icon: "☀️"; property string temp: "--°C"; property string condition: "Loading..."
                property string humidity: "--%"; property string wind: "--"

                Process {
                    running: true
                    command: ["sh", "-c", "curl -s 'wttr.in/?m&format=%c|%t|%C|%h|%w'"]
                    stdout: SplitParser {
                        onRead: (data) => {
                            let parts = data.trim().split("|")
                            if (parts.length >= 5) {
                                weatherCard.icon = parts[0].trim(); weatherCard.temp = parts[1].trim()
                                weatherCard.condition = parts[2].trim(); weatherCard.humidity = parts[3].trim()
                                weatherCard.wind = parts[4].trim()
                            }
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent; spacing: 8
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: weatherCard.icon; font.pixelSize: 38 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: weatherCard.temp; color: "#ffffff"; font.pixelSize: 24; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: weatherCard.condition; color: "#bac2de"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                        Text { text: "💧 " + weatherCard.humidity; color: "#89b4fa"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                        Text { text: "󰖝 " + weatherCard.wind; color: "#94e2d5"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                    }
                }
            }

            Rectangle {
                id: calCard
                width: parent.width - 170 - 12; height: parent.height; color: "#2a2b3d"; radius: 10
                property date displayDate: new Date()
                property int year: displayDate.getFullYear(); property int month: displayDate.getMonth()
                property int today: calRoot.now.getDate()
                property bool isCurrentMonth: displayDate.getFullYear() === calRoot.now.getFullYear() && displayDate.getMonth() === calRoot.now.getMonth()
                property int daysInMonth: new Date(year, month + 1, 0).getDate()
                property int firstDay: (new Date(year, month, 1).getDay() + 6) % 7

                function changeMonth(delta) { displayDate = new Date(year, month + delta, 1) }

                Column {
                    anchors.fill: parent; anchors.margins: 12; spacing: 6
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 12
                        Rectangle {
                            width: 22; height: 22; radius: 4; color: prevMouse.containsMouse ? "#313244" : "transparent"; anchors.verticalCenter: parent.verticalCenter
                            Text { anchors.centerIn: parent; text: "❮"; color: "#89b4fa"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                            MouseArea { id: prevMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: calCard.changeMonth(-1) }
                        }
                        Text { anchors.verticalCenter: parent.verticalCenter; text: Qt.formatDateTime(calCard.displayDate, "MMMM yyyy"); color: "#89b4fa"; font.pixelSize: 14; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                        Rectangle {
                            width: 22; height: 22; radius: 4; color: nextMouse.containsMouse ? "#313244" : "transparent"; anchors.verticalCenter: parent.verticalCenter
                            Text { anchors.centerIn: parent; text: "❯"; color: "#89b4fa"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                            MouseArea { id: nextMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: calCard.changeMonth(1) }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 4
                        Repeater {
                            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                            delegate: Item {
                                width: 30; height: 20
                                Text { anchors.centerIn: parent; text: modelData; color: "#a6adc8"; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                            }
                        }
                    }

                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter; columns: 7; spacing: 4
                        Repeater {
                            model: 42
                            delegate: Rectangle {
                                width: 30; height: 22; radius: 4
                                property int dayNumber: index - calCard.firstDay + 1
                                property bool isValid: dayNumber >= 1 && dayNumber <= calCard.daysInMonth
                                property bool isToday: calCard.isCurrentMonth && isValid && dayNumber === calCard.today
                                color: isToday ? "#89b4fa" : (gridMouse.containsMouse && isValid ? "#313244" : "transparent")
                                Text {
                                    anchors.centerIn: parent; visible: parent.isValid; text: parent.dayNumber; color: parent.isToday ? "#1e1e2e" : "#cdd6f4"
                                    font.bold: parent.isToday; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                                }
                                MouseArea {
                                    id: gridMouse; anchors.fill: parent; enabled: parent.isValid; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: { openGCalProc.running = true; calRoot.closeRequested() }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
