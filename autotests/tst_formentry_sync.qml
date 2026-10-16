// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtTest
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.forms.private.cards as Cards
import org.kde.kirigami.forms.private.flat as Flat

TestCase {
    id: testCase
    name: "FormEntrySync"
    width: 1200
    height: 800
    visible: true
    when: windowShown

    Component {
        id: cardsForm
        Cards.Form {
            width: 1200
            Cards.FormGroup {
                Cards.FormEntry {
                    objectName: "entry"
                    title: "EntryTitle"
                    fullWidth: true
                    contentItem: QQC.TextField { text: "Value" }
                }
            }
        }
    }

    Component {
        id: flatForm
        Flat.Form {
            width: 1200
            Flat.FormGroup {
                Flat.FormEntry {
                    objectName: "entry"
                    title: "EntryTitle"
                    fullWidth: true
                    contentItem: QQC.TextField { text: "Value" }
                }
            }
        }
    }

    function visibleTitles(item) {
        let count = 0;
        if (item instanceof QQC.Label && item.text === "EntryTitle" && item.visible) {
            count++;
        }
        for (const child of item.children) {
            count += visibleTitles(child);
        }
        return count;
    }

    function test_cardsFullWidthKeepsTitle() {
        const form = createTemporaryObject(cardsForm, testCase);
        verify(form);
        tryCompare(form, "__collapsed", false);
        const entry = findChild(form, "entry");
        tryVerify(() => visibleTitles(entry) === 1);
    }

    function test_flatEntryHasValidMargin_data() {
        return [
            {tag: "full-width", fullWidth: true, collapsed: false},
            {tag: "collapsed", fullWidth: false, collapsed: true},
            {tag: "label-aligned", fullWidth: false, collapsed: false},
        ];
    }

    function test_flatEntryHasValidMargin(data) {
        failOnWarning(/ReferenceError: padding is not defined/);
        const form = createTemporaryObject(flatForm, testCase);
        verify(form);
        const entry = findChild(form, "entry");
        entry.fullWidth = data.fullWidth;
        if (data.collapsed) {
            form.width = 1;
        }
        tryCompare(form, "__collapsed", data.collapsed);
        const mainLayout = entry.children.find(child => child instanceof RowLayout);
        verify(mainLayout);
        if (data.fullWidth || data.collapsed) {
            tryCompare(mainLayout.anchors, "leftMargin", 0);
        } else {
            tryVerify(() => mainLayout.anchors.leftMargin > 0);
        }
        tryVerify(() => visibleTitles(entry) === 1);
    }

    function test_flatEntryDoesNotForceCardWidth() {
        const form = createTemporaryObject(flatForm, testCase);
        verify(form);
        const entry = findChild(form, "entry");
        entry.fullWidth = false;
        entry.contentItem.implicitWidth = 80;
        tryVerify(() => entry.implicitWidth < Platform.Units.gridUnit * 20);
        tryCompare(entry, "implicitWidth", 80 + Platform.Units.largeSpacing * 2);
        entry.contentItem.implicitWidth = 160;
        tryCompare(entry, "implicitWidth", 160 + Platform.Units.largeSpacing * 2);
        entry.contentItem.Layout.preferredWidth = Platform.Units.gridUnit * 30;
        tryCompare(entry, "implicitWidth", Platform.Units.gridUnit * 30 + Platform.Units.largeSpacing * 2);
    }
}
