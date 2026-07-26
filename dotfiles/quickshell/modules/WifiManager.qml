import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Io

Item {
    id: wifiMgr

    readonly property bool isPowered: Networking.wifiEnabled

    readonly property var wifiDevice: {
        let devs = Networking.devices ? Networking.devices.values : [];
        let fallbackDev = null;
        for (let i = 0; i < devs.length; i++) {
            let d = devs[i];
            if (d && d.scannerEnabled !== undefined && d.networks !== undefined) {
                if (d.networks.values && d.networks.values.length > 0) {
                    return d;
                }
                if (!fallbackDev) fallbackDev = d;
            }
        }
        return fallbackDev;
    }

    property int refreshTicket: 0
    readonly property var accessPoints: {
        let dummy = refreshTicket;
        return (isPowered && wifiDevice && wifiDevice.networks) ? wifiDevice.networks.values : [];
    }

    property string activeSsid: ""
    property string tempActiveSsid: ""
    property string activeDevice: ""
    property string pendingSsid: ""

    property int signalTicket: 0
    property var signalMap: ({})
    property var tempSignalMap: ({})
    signal passwordRequired(string ssid)


    function getSignalStrength(netObj, ssid) {
        let dummy = signalTicket;

        if (ssid !== "") {
            let key = ssid.trim().toLowerCase();
            if (signalMap[key] !== undefined && typeof signalMap[key] === "number" && signalMap[key] > 0) {
                return signalMap[key];
            }
        }

        if (netObj) {
            let s = netObj.strength !== undefined ? netObj.strength : (netObj.signal !== undefined ? netObj.signal : -1);
            if (typeof s === "number" && s > 0) {
                if (s <= 5) return s * 20;
                if (s <= 100) return s;
            }
        }

        return 70;
    }

    Process {
        id: signalProc
        command: ["nmcli", "-t", "-f", "SIGNAL,SSID", "dev", "wifi"]
        stdout: SplitParser {
            onRead: (line) => {
                let str = line.trim();
                let parts = str.split(":");
                let sigVal = -1;
                let ssidIndex = -1;

                for (let i = 0; i < parts.length - 1; i++) {
                    let val = parseInt(parts[i].trim());
                    if (!isNaN(val) && val >= 0 && val <= 100 && parts[i].trim() === val.toString()) {
                        sigVal = val;
                        ssidIndex = i + 1;
                        break;
                    }
                }

                if (sigVal !== -1 && ssidIndex !== -1) {
                    let ssid = parts.slice(ssidIndex).join(":").trim();
                    if (ssid !== "" && ssid !== "--") {
                        let key = ssid.toLowerCase();
                        wifiMgr.tempSignalMap[key] = Math.max(wifiMgr.tempSignalMap[key] || 0, sigVal);
                    }
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                wifiMgr.signalMap = Object.assign({}, wifiMgr.tempSignalMap);
                wifiMgr.signalTicket++;
                wifiMgr.refreshTicket++;
            }
        }
    }

    Process {
        id: devShowProc
        command: ["nmcli", "-t", "-f", "TYPE,CONNECTION,DEVICE", "dev"]
        stdout: SplitParser {
            onRead: (line) => {
                let str = line.trim();
                if (str.startsWith("wifi:") || str.startsWith("802-11-wireless:")) {
                    let parts = str.split(":");
                    if (parts.length >= 2) {
                        let conName = parts[1].trim();
                        if (conName !== "" && conName !== "--" && conName !== "disconnected") {
                            wifiMgr.tempActiveSsid = conName;
                        }
                        if (parts.length >= 3 && parts[2].trim() !== "") {
                            wifiMgr.activeDevice = parts[2].trim();
                        }
                    }
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                wifiMgr.activeSsid = wifiMgr.tempActiveSsid;
            }
        }
    }

    function checkActiveConnection() {
        tempActiveSsid = "";
        tempSignalMap = Object.assign({}, signalMap);
        devShowProc.running = false;
        devShowProc.running = true;
        signalProc.running = false;
        signalProc.running = true;
    }

    Timer {
        id: pollTimer
        interval: 2000
        running: wifiMgr.isPowered
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            wifiMgr.checkActiveConnection();
        }
    }

    Timer {
        id: recheckTimer
        interval: 2500
        repeat: false
        onTriggered: {
            pollTimer.start();
            wifiMgr.checkActiveConnection();
        }
    }

    onIsPoweredChanged: {
        if (isPowered && wifiDevice) {
            wifiDevice.scannerEnabled = true;
            checkActiveConnection();
        } else {
            activeSsid = "";
        }
    }

    function togglePower() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function requestScan() {
        if (wifiDevice && isPowered) {
            wifiDevice.scannerEnabled = false;
            wifiDevice.scannerEnabled = true;
            refreshTicket++;
            checkActiveConnection();
        }
    }

    function connectToNetwork(networkObject, password) {
        if (!networkObject) return;
        if (password && password !== "") {
            networkObject.connectWithPsk(password);
        } else {
            networkObject.connect();
        }
        pollTimer.restart();
        checkActiveConnection();
    }

    function disconnectActive() {
        if (wifiDevice && wifiDevice.networks) {
            let list = wifiDevice.networks.values;
            for (let i = 0; i < list.length; i++) {
                if (list[i] && (list[i].connected || (activeSsid !== "" && list[i].name === activeSsid))) {
                    list[i].disconnect();
                }
            }
        }

        let devName = activeDevice !== "" ? activeDevice : ((wifiDevice && wifiDevice.name) ? wifiDevice.name : "wlan0");
        disconnectProc.command = ["nmcli", "dev", "disconnect", devName];
        disconnectProc.running = false;
        disconnectProc.running = true;

        activeSsid = "";
        tempActiveSsid = "";
        pollTimer.stop();
        recheckTimer.restart();
    }

    Process { id: disconnectProc }

    Component.onCompleted: {
        if (isPowered && wifiDevice) {
            wifiDevice.scannerEnabled = true;
        }
        checkActiveConnection();
    }
}
