import KCMWaydroid 1.0
import QtQuick 2.12
import QtQuick.Controls 2.12 as Controls
import QtQuick.Layouts 1.15
import org.kde.kcm 1.2
import org.kde.kirigami 2.7 as Kirigami

SimpleKCM {
    icon: waydroid
    spacing: Kirigami.Units.smallSpacing

    Waydroid {
        id: waydroid
    }

    //Gets a CheckState from a String. Needed because waydroid properties that should be bools could be set to any value.
    function getCheckState(value) {
        if (value === 'true')
            return Qt.Checked;
        else if (value === 'false')
            return Qt.Unchecked;
        else
            return Qt.PartiallyChecked;
    }

    Kirigami.FormLayout {
        id: form
        enabled: waydroid.isSessionRunning() //We cannot get/set properties if the session isn't running

        Kirigami.Heading {
            level: 2
            text: "Properties"
            elide: Text.ElideRight
            textFormat: Text.PlainText
        }

        Controls.CheckBox {
            id: multiWindowCheck
            text: i18n("Enable multi-window mode")
            tristate: true
            checkState: getCheckState(waydroid.getProp("multi_windows"))
            onClicked: {
                waydroid.setProp("multi_windows", multiWindowCheck.checked);
            }
            nextCheckState: function() {
                if (checkState === Qt.Checked)
                    return Qt.Unchecked;
                else
                    return Qt.Checked;
            }
        }

        Controls.CheckBox {
            id: suspendCheck
            text: i18n("Allow the container to sleep when no apps are active")
            tristate: true
            checkState: getCheckState(waydroid.getProp("suspend"))
            onClicked: {
                waydroid.setProp("suspend", suspendCheck.checked);
            }
            nextCheckState: function() {
                if (checkState === Qt.Checked)
                    return Qt.Unchecked;
                else
                    return Qt.Checked;
            }
        }

        Controls.CheckBox {
            id: ueventCheck
            text: i18n("Allow android direct access to hotplugged devices")
            tristate: true
            checkState: getCheckState(waydroid.getProp("uevent"))
            onClicked: {
                waydroid.setProp("uevent", ueventCheck.checked);
            }
            nextCheckState: function() {
                if (checkState === Qt.Checked)
                    return Qt.Unchecked;
                else
                    return Qt.Checked;
            }
        }

        Controls.TextField {
            id: fakeTouchText
            Kirigami.FormData.label: i18n("Fake Touch for apps: ")
            text: waydroid.getProp("fake_touch")
            maximumLength: 91
            placeholderText: i18n("Fake touch list")
            Layout.fillWidth: true
            onEditingFinished: {
                waydroid.setProp("fake_touch", fakeTouchText.text);
            }
        }

        Controls.TextField {
            id: fakeWifiText
            Kirigami.FormData.label: i18n("Fake WiFi for apps: ")
            text: waydroid.getProp("fake_wifi")
            maximumLength: 91
            placeholderText: i18n("Fake WiFi list")
            Layout.fillWidth: true
            onEditingFinished: {
                waydroid.setProp("fake_wifi", fakeWifiText.text);
            }
        }

        Controls.Label
        {
            text: "Session status: "  + waydroid.getStatus();
        }
    }
}
