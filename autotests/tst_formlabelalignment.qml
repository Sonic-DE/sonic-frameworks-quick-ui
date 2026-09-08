// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC
import QtTest
import org.kde.kirigami.forms as Forms
import org.kde.kirigami.forms.private.cards as Cards
import org.kde.kirigami.forms.private.flat as Flat

TestCase {
    id: testCase

    name: "FormLabelAlignment"
    width: 2000
    height: 1000
    visible: true
    when: windowShown

    component EntryControl: QQC.TextField {
        text: "Value"
        implicitWidth: 180
    }

    Component {
        id: fixtureComponent

        Item {
            width: testCase.width
            height: testCase.height

            property alias flatForm: flatForm
            property alias cardsForm: cardsForm
            property Forms.FormAlignmentGroup alignmentGroup: Forms.FormAlignmentGroup {}

            Flat.Form {
                id: flatForm
                width: 1900
                height: 400

                property alias primaryGroup: flatPrimaryGroup
                property alias secondaryGroup: flatSecondaryGroup
                property alias primaryEntry: flatPrimary
                property alias secondaryEntry: flatSecondary

                Flat.FormGroup {
                    id: flatPrimaryGroup
                    Flat.FormEntry {
                        id: flatPrimary
                        title: "A long primary entry label"
                        fullWidth: true
                        contentItem: EntryControl {}
                    }
                }
                Flat.FormGroup {
                    id: flatSecondaryGroup
                    Flat.FormEntry {
                        id: flatSecondary
                        title: "Short"
                        contentItem: EntryControl {}
                    }
                }
            }

            Cards.Form {
                id: cardsForm
                y: 450
                width: 1900
                height: 400

                property alias primaryGroup: cardsPrimaryGroup
                property alias secondaryGroup: cardsSecondaryGroup
                property alias primaryEntry: cardsPrimary
                property alias secondaryEntry: cardsSecondary

                Cards.FormGroup {
                    id: cardsPrimaryGroup
                    Cards.FormEntry {
                        id: cardsPrimary
                        title: "A card entry with a longer primary label"
                        fullWidth: true
                        contentItem: EntryControl {}
                    }
                }
                Cards.FormGroup {
                    id: cardsSecondaryGroup
                    Cards.FormEntry {
                        id: cardsSecondary
                        title: "Short"
                        contentItem: EntryControl {}
                    }
                }
            }
        }
    }

    function init() {
        failOnWarning(/Binding loop detected/);
    }

    function createFixture() {
        const fixture = createTemporaryObject(fixtureComponent, testCase);
        verify(fixture);
        tryCompare(fixture.flatForm, "__collapsed", false);
        tryCompare(fixture.cardsForm, "__collapsed", false);
        return fixture;
    }

    function labelWidth(form) {
        return Math.max(form.primaryEntry.__textLabelWidth, form.secondaryEntry.__textLabelWidth);
    }

    function verifyAssignedWidths(form, expectedWidth) {
        waitForPolish(form);
        tryVerify(() => form.primaryGroup.__assignedWidthForLabels === Math.round(expectedWidth()));
        tryVerify(() => form.secondaryGroup.__assignedWidthForLabels === Math.round(expectedWidth()));
    }

    function test_fullWidthChanges_data() {
        return [{tag: "flat", form: "flatForm"}, {tag: "cards", form: "cardsForm"}];
    }

    function test_fullWidthChanges(data) {
        const fixture = createFixture();
        const form = fixture[data.form];
        tryCompare(form.primaryGroup, "__maxTextLabelWidth", 0);
        verifyAssignedWidths(form, () => labelWidth(form));

        form.primaryEntry.fullWidth = false;
        tryVerify(() => form.primaryEntry.__textLabelWidth > form.secondaryEntry.__textLabelWidth);
        tryVerify(() => form.primaryGroup.__maxTextLabelWidth === form.primaryEntry.__textLabelWidth);
        verifyAssignedWidths(form, () => labelWidth(form));

        if (data.form === "flatForm") {
            const label = form.primaryEntry.children.find(child => child instanceof QQC.Label);
            verify(label);
            tryVerify(() => label.x >= 0);
        }

        form.primaryEntry.fullWidth = true;
        tryCompare(form.primaryGroup, "__maxTextLabelWidth", 0);
        verifyAssignedWidths(form, () => labelWidth(form));
    }

    function test_titleAndFontChanges_data() {
        return test_fullWidthChanges_data();
    }

    function test_titleAndFontChanges(data) {
        const fixture = createFixture();
        const form = fixture[data.form];
        form.primaryEntry.fullWidth = false;
        verifyAssignedWidths(form, () => labelWidth(form));

        const oldTitleWidth = form.primaryEntry.__textLabelWidth;
        form.primaryEntry.title = "A substantially longer label with updated text";
        tryVerify(() => form.primaryEntry.__textLabelWidth !== oldTitleWidth);
        verifyAssignedWidths(form, () => labelWidth(form));

        const label = form.primaryEntry.children.find(child => child instanceof QQC.Label);
        verify(label);
        const oldFontWidth = form.primaryEntry.__textLabelWidth;
        if (label.font.pixelSize > 0) {
            label.font.pixelSize += 4;
        } else {
            label.font.pointSize += 4;
        }
        tryVerify(() => form.primaryEntry.__textLabelWidth !== oldFontWidth);
        verifyAssignedWidths(form, () => labelWidth(form));

        form.primaryEntry.title = "X";
        tryVerify(() => form.primaryEntry.__textLabelWidth < form.secondaryEntry.__textLabelWidth);
        verifyAssignedWidths(form, () => labelWidth(form));
    }

    function test_sharedAlignmentGroupUpdates() {
        const fixture = createFixture();
        const flat = fixture.flatForm;
        const cards = fixture.cardsForm;
        flat.Forms.FormAlignmentGroup.group = fixture.alignmentGroup;
        cards.Forms.FormAlignmentGroup.group = fixture.alignmentGroup;
        const sharedWidth = () => Math.max(labelWidth(flat), labelWidth(cards));

        flat.primaryEntry.fullWidth = false;
        verifyAssignedWidths(flat, sharedWidth);
        verifyAssignedWidths(cards, sharedWidth);

        cards.primaryEntry.fullWidth = false;
        verifyAssignedWidths(flat, sharedWidth);
        verifyAssignedWidths(cards, sharedWidth);

        cards.visible = false;
        verifyAssignedWidths(flat, () => labelWidth(flat));

        cards.visible = true;
        verifyAssignedWidths(flat, sharedWidth);
        verifyAssignedWidths(cards, sharedWidth);

        flat.primaryEntry.fullWidth = true;
        cards.primaryEntry.fullWidth = true;
        verifyAssignedWidths(flat, sharedWidth);
        verifyAssignedWidths(cards, sharedWidth);
    }
}
