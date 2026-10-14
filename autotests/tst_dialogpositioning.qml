// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import QtTest
import org.kde.kirigami.dialogs as Dialogs
import org.kde.kirigami.platform as Platform

TestCase {
    id: testCase

    name: "DialogPositioning"
    width: 800
    height: 800
    visible: true
    when: windowShown

    component PositionedDialog: Dialogs.Dialog {
        id: dialog

        parent: testCase
        title: "Positioning"
        preferredWidth: 300
        standardButtons: T.Dialog.Ok
        popupType: T.Popup.Item
        enter: null
        exit: null

        property real bodyHeight: 100
        Rectangle {
            implicitWidth: 200
            implicitHeight: dialog.bodyHeight
        }
    }

    Component {
        id: dialogComponent
        PositionedDialog {}
    }

    Component {
        id: boundHeightComponent
        PositionedDialog {
            property real selectedHeight: 600
            height: selectedHeight
        }
    }

    Component {
        id: animatedComponent
        Dialogs.Dialog {
            parent: testCase
            title: "Animated positioning"
            preferredWidth: 300
            standardButtons: T.Dialog.Ok
            popupType: T.Popup.Item
            margins: 40
            Rectangle {
                implicitWidth: 200
                implicitHeight: 2000
            }
        }
    }

    Component {
        id: wrappingComponent
        Dialogs.Dialog {
            parent: testCase
            title: "Wrapping content"
            standardButtons: T.Dialog.Ok
            maximumWidth: 300
            preferredWidth: 300
            popupType: T.Popup.Item
            enter: null
            exit: null

            property alias label: label
            QQC.Label {
                id: label
                text: "Text that should wrap when the available dialog width changes. ".repeat(6)
                wrapMode: Text.WordWrap
            }
        }
    }

    function init() {
        testCase.width = 800;
        testCase.height = 800;
        failOnWarning(/Binding loop detected/);
    }

    function openDialog(component, properties = {}) {
        const dialog = createTemporaryObject(component, testCase, properties);
        verify(dialog);
        dialog.open();
        tryCompare(dialog, "opened", true);
        waitForPolish(dialog.contentItem);
        return dialog;
    }

    function verifyCentered(dialog) {
        waitForPolish(dialog.contentItem);
        tryVerify(() => Math.abs(dialog.y - Math.round((dialog.parent.height - dialog.height) / 2)) < 0.01);
        verify(dialog.y >= 0);
        verify(dialog.y + dialog.height <= dialog.parent.height + 1);
    }

    function test_centering_data() {
        return [
            {tag: "implicit", properties: {}},
            {tag: "preferred", properties: {preferredHeight: 450}},
            {tag: "explicit-tall", properties: {height: 600}},
            {tag: "explicit-short", properties: {height: 300, preferredHeight: 450}},
            {tag: "maximum-height", properties: {bodyHeight: 2000, maximumHeight: 300}},
            {tag: "constrained-by-margins", properties: {bodyHeight: 2000, margins: 40}},
            {tag: "window-explicit", properties: {height: 600, popupType: T.Popup.Window}},
        ];
    }

    function test_centering(data) {
        const dialog = openDialog(dialogComponent, data.properties);
        verifyCentered(dialog);
        dialog.close();
    }

    function test_parentAndExplicitHeightChanges() {
        const dialog = openDialog(boundHeightComponent);
        verifyCentered(dialog);

        testCase.height = 700;
        verifyCentered(dialog);
        dialog.selectedHeight = 300;
        tryCompare(dialog, "height", 300);
        verifyCentered(dialog);

        dialog.bodyHeight = 350;
        verifyCentered(dialog);
        dialog.preferredHeight = 600;
        verifyCentered(dialog);
        dialog.close();
    }

    function test_automaticHeightChanges() {
        const dialog = openDialog(dialogComponent);
        verifyCentered(dialog);

        dialog.bodyHeight = 2000;
        tryVerify(() => dialog.height > 600);
        verifyCentered(dialog);
        testCase.height = 420;
        tryVerify(() => dialog.height <= 420);
        verifyCentered(dialog);

        dialog.bodyHeight = 80;
        tryVerify(() => dialog.height < 420);
        verifyCentered(dialog);
        dialog.close();
        tryCompare(dialog, "opened", false);
        dialog.open();
        tryCompare(dialog, "opened", true);
        verifyCentered(dialog);
        dialog.close();
    }

    function test_wrappingContent() {
        const dialog = openDialog(wrappingComponent);
        tryCompare(dialog, "width", 300);
        waitForPolish(dialog.label);
        verify(waitForRendering(dialog.contentItem));
        verifyCentered(dialog);
        const oldHeight = dialog.height;

        dialog.maximumWidth = 500;
        tryCompare(dialog, "width", 500);
        waitForPolish(dialog.label);
        tryVerify(() => dialog.height < oldHeight);
        verifyCentered(dialog);
        dialog.close();
    }

    function test_animationOffset() {
        const dialog = openDialog(dialogComponent, {height: 600});
        verifyCentered(dialog);
        dialog.opacity = 0.5;
        tryVerify(() => Math.abs(dialog.y - Math.round((dialog.parent.height - dialog.height) / 2) - Platform.Units.gridUnit) < 0.01);
        dialog.opacity = 1;
        verifyCentered(dialog);
        dialog.close();
    }

    function test_defaultTransitions() {
        const dialog = createTemporaryObject(animatedComponent, testCase);
        verify(dialog);
        dialog.open();
        tryCompare(dialog, "opened", true, Platform.Units.longDuration * 2 + 1000);
        verifyCentered(dialog);
        dialog.close();
        tryCompare(dialog, "visible", false, Platform.Units.longDuration * 2 + 1000);
    }

    function test_customYIsPreserved() {
        const dialog = openDialog(dialogComponent, {height: 600, y: 25});
        compare(dialog.y, 25);
        dialog.height = 300;
        testCase.height = 900;
        waitForPolish(dialog.contentItem);
        compare(dialog.y, 25);
        dialog.close();
    }
}
