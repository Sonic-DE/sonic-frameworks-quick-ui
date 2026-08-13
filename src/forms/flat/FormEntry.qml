/*
 *  SPDX-FileCopyrightText: 2025 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.layouts as KirigamiLayouts
import org.kde.kirigami.forms.private.templates as FT

FT.FormEntry {
    id: root

    implicitWidth: Math.max(contentItemWrapper.implicitWidth +  Platform.Units.largeSpacing * 2, Platform.Units.gridUnit * 20 +  Platform.Units.largeSpacing * 2)
    implicitHeight: mainLayout.implicitHeight

    Layout.fillWidth: true

    //Internal: never rely on this
    readonly property real __textLabelWidth: label.implicitWidth

    QQC.Label {
        id: label
        anchors {
            top: parent.top
            right: mainLayout.left
            rightMargin: Platform.Units.largeSpacing
            topMargin: root.contentItem.parent.y + root.contentItem.KirigamiLayouts.FormData.buddyFor.y + layout.y + root.contentItem.KirigamiLayouts.FormData.buddyFor.height/2 - label.height/2
        }
        visible: text.length > 0 && !mainLayout.formLayout.__collapsed && !root.fullWidth
        Primitives.MnemonicData.enabled: {
                const buddy = root.contentItem?.KirigamiLayouts.FormData.buddyFor;
                if (buddy && buddy.enabled && buddy.visible && buddy.activeFocusOnTab) {
                    // Only set mnemonic if the buddy doesn't already have one.
                    const buddyMnemonic = buddy.Primitives.MnemonicData;
                    return !buddyMnemonic.label || !buddyMnemonic.enabled;
                } else {
                    return false;
                }
            }
        Primitives.MnemonicData.controlType: Primitives.MnemonicData.FormLabel
        Primitives.MnemonicData.label: root.title
        text: Primitives.MnemonicData.richTextLabel
        Accessible.name: Primitives.MnemonicData.plainTextLabel
        // We should use this instead of the binding but this makes qt crash due to QTBUG-146127
        // Accessible.labelFor: visible ? root.contentItem : null
        Shortcut {
            sequence: label.Primitives.MnemonicData.sequence
            onActivated: {
                const buddy = root.contentItem?.KirigamiLayouts.FormData.buddyFor;
                buddy.forceActiveFocus(Qt.ShortcutFocusReason);

                if (buddy instanceof T.AbstractButton) {
                    buddy.animateClick();
                } else if (buddy instanceof T.ComboBox) {
                    buddy.popup.open();
                }
            }
        }
        TapHandler {
            onTapped: {
                if (!root.clickEnabled) {
                    return;
                }
                const buddy = root.contentItem?.KirigamiLayouts.FormData.buddyFor;
                buddy.forceActiveFocus(Qt.ShortcutFocusReason);
                root.clicked();
            }
        }
    }

    // Replace with Accessible.labelFor once QTBUG-146127 is fixed
    Binding {
        target: root.contentItem.Accessible
        property: "labelledBy"
        value: label.visible ? label : layout.header
    }

    RowLayout {
        id: mainLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: mainLayout.formLayout.__collapsed || root.fullWidth ? padding : formGroup?.__assignedWidthForLabels + Platform.Units.largeSpacing * 2
        }

        spacing: Platform.Units.smallSpacing

        readonly property Item formLayout: {
            let candidate = root.parent;
            if (!candidate) {
                return null;
            }
            while (candidate) {
                if (candidate instanceof Form) {
                    return candidate;
                }
                candidate = candidate.parent
            }
            console.warn("Warning: FormEntry not inside a Form")
            return null
        }
        readonly property Item formGroup: {
            let candidate = root.parent;
            if (!candidate) {
                return null;
            }
            while (candidate) {
                if (candidate instanceof FormGroup) {
                    return candidate;
                }
                candidate = candidate.parent
            }
            console.warn("Warning: FormEntry not inside a FormGroup")
            return null
        }



        RowLayout {
            id: leadingItems
            visible: children.length > 0
            spacing: Platform.Units.smallSpacing
            children: root.leadingItems
        }
        ColumnLayout {
            id: layout
            Layout.fillWidth: true
            Layout.minimumWidth: contentItem?.Layout.minimumWidth
            Layout.preferredWidth: {
                if (!contentItem) {
                    return -1;
                } else if (contentItem.Layout.preferredWidth > 0) {
                    return contentItem.Layout.preferredWidth;
                }
                return contentItem.implicitWidth;
            }

            Layout.maximumWidth: contentItem?.Layout.maximumWidth

            Binding {
                readonly property bool firstEntry: root.parent.children[0] === root
                when: firstEntry
                titleLabel.topPadding: 0
            }

            QQC.Label {
                id: titleLabel
                Layout.fillWidth: true
                topPadding: Platform.Units.largeSpacing
                visible: (mainLayout.formLayout.__collapsed  || root.fullWidth) && text.length > 0
                text: label.Primitives.MnemonicData.richTextLabel
            }

            RowLayout {
                Layout.fillWidth: true
                QQC.Control {
                    id: contentItemWrapper
                    padding: 0
                    implicitWidth: contentItem.Layout.preferredWidth > 0 ? contentItem.Layout.preferredWidth : contentItem.implicitWidth
                    Layout.fillWidth: contentItem.Layout.fillWidth
                    Layout.minimumWidth: contentItem.Layout.minimumWidth
                    Layout.preferredWidth: contentItem.Layout.preferredWidth
                    Layout.maximumWidth: contentItem.Layout.maximumWidth
                    contentItem: root.contentItem
                }
                RowLayout {
                    id: trailingItems
                    Layout.minimumWidth: implicitWidth
                    visible: children.length > 0
                    spacing: Platform.Units.smallSpacing
                    children: root.trailingItems
                }
            }

            QQC.Label {
                Layout.fillWidth: true
                font: Platform.Theme.smallFont
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                visible: text.length > 0
                text: root.subtitle
                leftPadding:
                    Application.layoutDirection === Qt.LeftToRight
                    ? (root.contentItem.KirigamiLayouts.FormData.buddyFor?.indicator?.width ?? 0) + root.contentItem.KirigamiLayouts.FormData.buddyFor?.spacing
                    : padding
                rightPadding: Application.layoutDirection === Qt.RightToLeft
                    ? (root.contentItem.KirigamiLayouts.FormData.buddyFor?.indicator?.width ?? 0) + root.contentItem.KirigamiLayouts.FormData.buddyFor?.spacing
                    : padding
                onLinkActivated: (link) => Qt.openUrlExternally(link)
                HoverHandler {
                    cursorShape: parent.hoveredLink.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
        }
    }
}
