/*
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC
import QtTest
import org.kde.kirigami.controls as Kirigami
import "../src/controls/private" as KirigamiPrivate

TestCase {
    id: testCase

    name: "ActionsMenu"
    width: 640
    height: 480
    visible: true
    when: windowShown

    Component {
        id: fixedSizeComponent

        Rectangle {
            objectName: "display-content"
            width: 200
            height: 50
        }
    }

    Component {
        id: implicitSizeComponent

        Rectangle {
            objectName: "display-content"
            implicitWidth: 200
            implicitHeight: 50
        }
    }

    Component {
        id: anchoredSizeComponent

        Rectangle {
            objectName: "display-content"
            implicitWidth: 200
            implicitHeight: 50
            anchors.fill: parent
        }
    }

    Component {
        id: focusableComponent

        QQC.TextField {
            objectName: "display-content"
            implicitWidth: 200
            height: 50
            focus: true
        }
    }

    Component {
        id: boundHeightComponent

        Rectangle {
            objectName: "display-content"
            property real requestedHeight: 50
            width: 200
            height: requestedHeight
        }
    }

    Component {
        id: menuComponent

        KirigamiPrivate.ActionsMenu {
            id: menu

            parent: testCase
            popupType: QQC.Popup.Item
            enter: null
            exit: null

            property Component testDisplayComponent
            property bool initiallyVisible: true
            property Kirigami.Action testAction: Kirigami.Action {
                text: "Custom content"
                visible: menu.initiallyVisible
                displayComponent: menu.testDisplayComponent
            }

            actions: [testAction]
        }
    }

    function init() {
        failOnWarning(/.*/);
    }

    function createMenu(component, initiallyVisible = true) {
        const menu = createTemporaryObject(menuComponent, testCase, {
            testDisplayComponent: component,
            initiallyVisible: initiallyVisible,
        });
        verify(menu);
        menu.open();
        tryCompare(menu, "opened", true);
        tryCompare(menu, "count", 1);
        return menu;
    }

    function test_customContentSize_data() {
        return [
            {tag: "fixed-visible", component: fixedSizeComponent, visible: true},
            {tag: "fixed-hidden", component: fixedSizeComponent, visible: false},
            {tag: "implicit-visible", component: implicitSizeComponent, visible: true},
            {tag: "implicit-hidden", component: implicitSizeComponent, visible: false},
            {tag: "anchored-visible", component: anchoredSizeComponent, visible: true},
            {tag: "anchored-hidden", component: anchoredSizeComponent, visible: false},
        ];
    }

    function test_customContentSize(data) {
        const menu = createMenu(data.component, data.visible);
        const row = menu.itemAt(0);
        const content = findChild(row, "display-content");
        verify(content);

        tryCompare(content, "height", 50);
        tryVerify(() => row.implicitWidth > 0);
        tryCompare(row, "height", data.visible ? 50 : 0);
        compare(content.parent.action, menu.testAction);

        menu.testAction.visible = false;
        tryCompare(row, "visible", false);
        tryCompare(row, "height", 0);
        compare(content.height, 50);

        menu.testAction.visible = true;
        tryCompare(row, "visible", true);
        tryCompare(row, "height", 50);
        compare(content.height, 50);

        menu.width = 300;
        tryVerify(() => row.width > 200);
        tryCompare(content, "width", row.width);
        compare(content.height, 50);
        menu.close();
    }

    function test_heightBindingSurvivesHiding() {
        const menu = createMenu(boundHeightComponent);
        const row = menu.itemAt(0);
        const content = findChild(row, "display-content");
        verify(content);
        tryCompare(row, "height", 50);

        menu.testAction.visible = false;
        tryCompare(row, "height", 0);
        content.requestedHeight = 80;
        tryCompare(content, "height", 80);
        compare(row.height, 0);

        menu.testAction.visible = true;
        tryCompare(row, "height", 80);
        compare(content.height, 80);
        menu.close();
    }

    function test_implicitSizeChangesWhileHidden() {
        const menu = createMenu(implicitSizeComponent);
        const row = menu.itemAt(0);
        const content = findChild(row, "display-content");
        verify(content);

        menu.testAction.visible = false;
        tryCompare(row, "height", 0);
        content.implicitWidth = 240;
        content.implicitHeight = 80;
        tryCompare(row, "implicitWidth", 240);
        tryCompare(content, "height", 80);
        compare(row.height, 0);

        menu.testAction.visible = true;
        tryCompare(row, "height", 80);
        compare(content.height, 80);
        menu.close();
    }

    function test_loadedContentRetainsFocus() {
        const menu = createMenu(focusableComponent);
        const row = menu.itemAt(0);
        const content = findChild(row, "display-content");
        verify(content);

        row.forceActiveFocus();
        tryCompare(content, "activeFocus", true);
        keyClick(Qt.Key_A);
        tryCompare(content, "text", "a");
        menu.close();
    }
}
