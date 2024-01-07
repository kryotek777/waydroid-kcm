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

    function initProp(control, propName) {
        control.enabled = false;

        waydroid.initProp(propName, function(value)
        {
            if(control instanceof Controls.CheckBox)
            {
                control.checkState = getCheckState(value);
            }
            else if(control instanceof Controls.TextField)
            {
                control.text = value;
            }
            else
            {
                console.log("Error! control not a CheckBox nor a TextField");
            }            

            control.enabled = true;
        });
    }

    function setProp(control, propName, value) {
        control.enabled = false;

        waydroid.setProp(propName, value, function(result)
        {
            control.enabled = true;
        });
    }

    function cycleCheckState(value) {
        if (value === Qt.Checked)
            return Qt.Unchecked;
        else if (value === Qt.Unchecked)
            return Qt.Checked;
        else // Qt.PartiallyChecked
            return Qt.Unchecked;
    }

    Kirigami.FormLayout {
        id:form
    
        Kirigami.FormLayout {
            id: controls
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
                Component.onCompleted: initProp(multiWindowCheck, "multi_windows");
                onClicked: setProp(multiWindowCheck, "multi_windows", multiWindowCheck.checked);
                nextCheckState: function() { return cycleCheckState(checkState); }
            }

            Controls.CheckBox {
                id: cursorSubsurfaceCheck
                text: i18n("Draw cursor on subsurface")
                tristate: true
                Component.onCompleted: initProp(cursorSubsurfaceCheck, "cursor_on_subsurface");
                onClicked: setProp(cursorSubsurfaceCheck, "cursor_on_subsurface", cursorSubsurfaceCheck.checked);
                nextCheckState: function() { return cycleCheckState(checkState); }
            }

            Controls.CheckBox {
                id: invertColorsCheck
                text: i18n("Invert colors (works only on a patched mutter)")
                tristate: true
                Component.onCompleted: initProp(invertColorsCheck, "invert_colors");
                onClicked: setProp(invertColorsCheck, "invert_colors", invertColorsCheck.checked);
                nextCheckState: function() { return cycleCheckState(checkState); }
            }

            Controls.CheckBox {
                id: suspendCheck
                text: i18n("Allow the container to sleep when no apps are active")
                tristate: true
                Component.onCompleted: initProp(suspendCheck, "suspend");
                onClicked: setProp(suspendCheck, "suspend", suspendCheck.checked);
                nextCheckState: function() { return cycleCheckState(checkState); }
            }

            Controls.CheckBox {
                id: ueventCheck
                text: i18n("Allow android direct access to hotplugged devices")
                tristate: true
                Component.onCompleted: initProp(ueventCheck, "uevent");
                onClicked: setProp(ueventCheck, "uevent", ueventCheck.checked);
                nextCheckState: function() { return cycleCheckState(checkState); }

            }

            Controls.TextField {
                id: fakeTouchText
                Kirigami.FormData.label: i18n("Fake Touch for apps: ")
                maximumLength: 91
                placeholderText: i18n("Fake touch list")
                Layout.fillWidth: true
                Component.onCompleted: initProp(fakeTouchText, "fake_touch");
                onEditingFinished: setProp(fakeTouchText, "fake_touch", fakeTouchText.text);
            }

            Controls.TextField {
                id: fakeWifiText
                Kirigami.FormData.label: i18n("Fake WiFi for apps: ")
                maximumLength: 91
                placeholderText: i18n("Fake WiFi list")
                Layout.fillWidth: true
                Component.onCompleted: initProp(fakeWifiText, "fake_wifi");
                onEditingFinished: setProp(fakeWifiText, "fake_wifi", fakeWifiText.text);

            }
        }

        Kirigami.Heading {
                level: 2
                text: "Status"
                elide: Text.ElideRight
                textFormat: Text.PlainText
        }

        Controls.Label
        {
            id: status
            text: "Session status: "  + waydroid.getStatus();
        }

        Row
        {
            Controls.Button {
                text: i18n("Restart container")
                id: restartBtn
                onClicked: {
                    waydroid.restartContainer();
                    waydroid.checkIfRunning();
                    controls.enabled = false;
                }
            }

            Controls.Button {
                text: i18n("Stop session")
                id: stopBtn
                enabled: waydroid.isSessionRunning()
                onClicked: {
                    controls.enabled = false;
                    waydroid.stopSession();
                    enabled = false;
                    status.text = "Session status: "  + waydroid.getStatus();
                }
            }

            Controls.Button {
                text: i18n("Update UI")
                id: updateUiBtn
                onClicked: {
                    waydroid.checkIfRunning();
                    controls.enabled = waydroid.isSessionRunning();
                    stopBtn.enabled = waydroid.isSessionRunning();
                    status.text = "Session status: "  + waydroid.getStatus();
                }
            }
        }
    }
}
