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

    property double _vibPeak: 0.0
    property double _vibRms: 0.0
    property double _vibStat: 0.0

    Connections {
        target: _activeVehicle
        function onMavlinkMessageReceived(message) {
            var namedValue = _customPlugin.mavlinkhelper.decodeNamedValueFloat(message);
            if (!namedValue) return;

            if (namedValue.name === "vib_peak") { _vibPeak = namedValue.value; }
            else if (namedValue.name === "vib_rms") { _vibRms = namedValue.value; }
            else if (namedValue.name === "vib_stat") { _vibStat = namedValue.value; }
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
                    model: ["SP10 Vibration Analyzer", "MavLink Info"]
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

                // SP10 Page
                Rectangle {
                    color: qgcPal.windowShadeDark; radius: 12; border.color: qgcPal.windowShade; border.width: 1
                    ScrollView {
                        anchors.fill: parent; anchors.margins: 20; contentWidth: availableWidth; clip: true
                        ColumnLayout {
                            width: parent.width; spacing: 30
                            Text { text: "Vibration Analyzer (Real-Time)"; font.pointSize: ScreenTools.largeFontPointSize; color: qgcPal.text; font.bold: true }
                            GridLayout {
                                columns: 1; Layout.fillWidth: true; rowSpacing: 15
                                Rectangle {
                                    Layout.fillWidth: true; height: 100; color: qgcPal.windowShade; radius: 8
                                    RowLayout { anchors.fill: parent; anchors.margins: 20; Text { text: "Peak Frequency"; color: qgcPal.colorGrey; font.pointSize: ScreenTools.mediumFontPointSize; Layout.fillWidth: true }; Text { text: _vibPeak.toFixed(1) + " Hz"; color: qgcPal.colorBlue; font.pointSize: ScreenTools.largeFontPointSize * 1.5; font.bold: true } }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; height: 100; color: qgcPal.windowShade; radius: 8
                                    RowLayout { anchors.fill: parent; anchors.margins: 20; Text { text: "RMS Vibration"; color: qgcPal.colorGrey; font.pointSize: ScreenTools.mediumFontPointSize; Layout.fillWidth: true }; Text { text: _vibRms.toFixed(3) + " g"; color: qgcPal.colorRed; font.pointSize: ScreenTools.largeFontPointSize * 1.5; font.bold: true } }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; height: 100; color: qgcPal.windowShade; radius: 8
                                    RowLayout { anchors.fill: parent; anchors.margins: 20; Text { text: "Envelope Spectra"; color: qgcPal.colorGrey; font.pointSize: ScreenTools.mediumFontPointSize; Layout.fillWidth: true }; Text { text: _vibStat > 0.5 ? "WARNING" : "NOMINAL"; color: _vibStat > 0.5 ? qgcPal.colorOrange : qgcPal.colorGreen; font.pointSize: ScreenTools.largeFontPointSize * 1.5; font.bold: true } }
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
                                            RowLayout { width: parent.width; Text { text: "vib_peak"; color: qgcPal.text; Layout.preferredWidth: 150 }; Text { text: _vibPeak.toFixed(2); color: qgcPal.colorGreen; font.bold: true; font.family: "monospace"; Layout.fillWidth: true } }
                                            RowLayout { width: parent.width; Text { text: "vib_rms"; color: qgcPal.text; Layout.preferredWidth: 150 }; Text { text: _vibRms.toFixed(4); color: qgcPal.colorGreen; font.bold: true; font.family: "monospace"; Layout.fillWidth: true } }
                                            RowLayout { width: parent.width; Text { text: "vib_stat"; color: qgcPal.text; Layout.preferredWidth: 150 }; Text { text: _vibStat.toFixed(1); color: qgcPal.colorGreen; font.bold: true; font.family: "monospace"; Layout.fillWidth: true } }
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
