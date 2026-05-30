import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import Custom.Widgets

Item {
    id: rootItem
    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _customPlugin: QGroundControl.corePlugin
    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75

    property double _envIrrad: 0.0
    property double _envVolt: 0.0
    property double _envCurr: 0.0
    property double _envPower: 0.0

    Connections {
        target: _activeVehicle
        function onMavlinkMessageReceived(message) {
            var namedValue = _customPlugin.mavlinkhelper.decodeNamedValueFloat(message);
            if (!namedValue) return;

            if (namedValue.name === "irrad") { _envIrrad = namedValue.value; }
            else if (namedValue.name === "volt") { _envVolt = namedValue.value; }
            else if (namedValue.name === "curr") { _envCurr = namedValue.value; }
            else if (namedValue.name === "power") { _envPower = namedValue.value; }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -_toolsMargin
        color: qgcPal.window

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 5

            TabBar {
                id: tabBar
                Layout.fillWidth: true
                background: Rectangle { color: "transparent" }

                Repeater {
                    model: ["SP03 Solar Estimation", "MavLink Info"]
                    TabButton {
                        text: modelData
                        contentItem: Text { text: parent.text; color: parent.checked ? qgcPal.text : qgcPal.colorGrey; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: parent.checked; font.pointSize: ScreenTools.isMobile ? ScreenTools.smallFontPointSize : ScreenTools.defaultFontPointSize }
                        background: Rectangle { color: parent.checked ? qgcPal.windowShadeDark : qgcPal.window; radius: 6; border.color: qgcPal.windowShade; border.width: 1; anchors.margins: 2 }
                    }
                }
            }

            StackLayout {
                id: stackLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabBar.currentIndex

                // SP03 Page
                Rectangle {
                    color: qgcPal.windowShadeDark; radius: 12; border.color: qgcPal.windowShade; border.width: 1
                    ScrollView {
                        anchors.fill: parent; anchors.margins: 20; contentWidth: availableWidth; clip: true
                        ColumnLayout {
                            width: parent.width; spacing: 30
                            Text { text: "SP03 Solar Yield Estimation"; font.pointSize: ScreenTools.largeFontPointSize; color: qgcPal.text; font.bold: true }
                            GridLayout {
                                columns: ScreenTools.isMobile ? 1 : 2; Layout.fillWidth: true; rowSpacing: 15; columnSpacing: 15
                                Rectangle {
                                    Layout.fillWidth: true; height: 140; color: qgcPal.windowShade; radius: 8
                                    ColumnLayout { anchors.centerIn: parent; spacing: 10; Text { text: "Irradiance"; color: qgcPal.colorGrey; font.pointSize: ScreenTools.mediumFontPointSize; Layout.alignment: Qt.AlignHCenter }; Text { text: _envIrrad.toFixed(1) + " W/m²"; color: qgcPal.colorOrange; font.pointSize: ScreenTools.largeFontPointSize * 1.5; font.bold: true; Layout.alignment: Qt.AlignHCenter } }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; height: 140; color: qgcPal.windowShade; radius: 8
                                    ColumnLayout { anchors.centerIn: parent; spacing: 10; Text { text: "Est. Voltage"; color: qgcPal.colorGrey; font.pointSize: ScreenTools.mediumFontPointSize; Layout.alignment: Qt.AlignHCenter }; Text { text: _envVolt.toFixed(1) + " V"; color: qgcPal.colorBlue; font.pointSize: ScreenTools.largeFontPointSize * 1.5; font.bold: true; Layout.alignment: Qt.AlignHCenter } }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; height: 140; color: qgcPal.windowShade; radius: 8
                                    ColumnLayout { anchors.centerIn: parent; spacing: 10; Text { text: "Est. Current"; color: qgcPal.colorGrey; font.pointSize: ScreenTools.mediumFontPointSize; Layout.alignment: Qt.AlignHCenter }; Text { text: _envCurr.toFixed(2) + " A"; color: qgcPal.colorGreen; font.pointSize: ScreenTools.largeFontPointSize * 1.5; font.bold: true; Layout.alignment: Qt.AlignHCenter } }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; height: 140; color: qgcPal.windowShade; radius: 8
                                    ColumnLayout { anchors.centerIn: parent; spacing: 10; Text { text: "Output Power"; color: qgcPal.colorGrey; font.pointSize: ScreenTools.mediumFontPointSize; Layout.alignment: Qt.AlignHCenter }; Text { text: _envPower.toFixed(1) + " W"; color: qgcPal.colorRed; font.pointSize: ScreenTools.largeFontPointSize * 1.5; font.bold: true; Layout.alignment: Qt.AlignHCenter } }
                                }
                            }
                        }
                    }
                }

                // MavLink Info Page
                Rectangle {
                    color: qgcPal.windowShadeDark; radius: 12; border.color: qgcPal.windowShade; border.width: 1
                    ScrollView {
                        anchors.fill: parent; anchors.margins: 20; contentWidth: availableWidth; clip: true
                        ColumnLayout {
                            width: parent.width; spacing: 15
                            Text { text: "MAVLink Info"; font.pointSize: ScreenTools.largeFontPointSize; color: qgcPal.text; font.bold: true }
                            Rectangle {
                                Layout.fillWidth: true; height: 300; color: qgcPal.window; radius: 8; border.color: qgcPal.windowShade; clip: true
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 15; spacing: 15
                                    RowLayout { Layout.fillWidth: true; Text { text: "Name"; color: qgcPal.colorGrey; font.bold: true; Layout.preferredWidth: 150 }; Text { text: "Value"; color: qgcPal.colorGrey; font.bold: true; Layout.fillWidth: true } }
                                    ScrollView {
                                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                                        ColumnLayout {
                                            width: parent.width; spacing: 10
                                            RowLayout { width: parent.width; Text { text: "irrad"; color: qgcPal.text; Layout.preferredWidth: 150 }; Text { text: _envIrrad.toFixed(2); color: qgcPal.colorGreen; font.bold: true; font.family: "monospace"; Layout.fillWidth: true } }
                                            RowLayout { width: parent.width; Text { text: "volt"; color: qgcPal.text; Layout.preferredWidth: 150 }; Text { text: _envVolt.toFixed(2); color: qgcPal.colorGreen; font.bold: true; font.family: "monospace"; Layout.fillWidth: true } }
                                            RowLayout { width: parent.width; Text { text: "curr"; color: qgcPal.text; Layout.preferredWidth: 150 }; Text { text: _envCurr.toFixed(2); color: qgcPal.colorGreen; font.bold: true; font.family: "monospace"; Layout.fillWidth: true } }
                                            RowLayout { width: parent.width; Text { text: "power"; color: qgcPal.text; Layout.preferredWidth: 150 }; Text { text: _envPower.toFixed(2); color: qgcPal.colorGreen; font.bold: true; font.family: "monospace"; Layout.fillWidth: true } }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
