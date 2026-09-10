// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
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

    function test_flatFullWidthHasValidMargin() {
        failOnWarning(/ReferenceError: padding is not defined/);
        const form = createTemporaryObject(flatForm, testCase);
        verify(form);
        const entry = findChild(form, "entry");
        tryVerify(() => visibleTitles(entry) === 1);
    }

    function test_flatEntryDoesNotForceCardWidth() {
        const form = createTemporaryObject(flatForm, testCase);
        verify(form);
        const entry = findChild(form, "entry");
        entry.fullWidth = false;
        entry.contentItem.implicitWidth = 80;
        tryVerify(() => entry.implicitWidth < Platform.Units.gridUnit * 20);
    }
}
