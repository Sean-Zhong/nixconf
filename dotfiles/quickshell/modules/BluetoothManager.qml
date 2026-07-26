import QtQuick
import Quickshell
import Quickshell.Bluetooth

Item {
    id: btMgr

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool isPowered: adapter ? Boolean(adapter.enabled) : false

    readonly property string connectedDeviceName: {
        if (!adapter || !adapter.devices) return "";
        let devs = adapter.devices.values;
        for (let i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].connected) return devs[i].name;
        }
        return "";
    }

    function togglePower() {
        if (adapter) {
            adapter.enabled = !adapter.enabled;
        }
    }

    function connectDevice(deviceModel) {
        if (!deviceModel.paired) {
            deviceModel.pair();
        }
        deviceModel.connectToDevice();
    }

    function disconnectDevice(deviceModel) {
        deviceModel.disconnectFromDevice();
    }
}
