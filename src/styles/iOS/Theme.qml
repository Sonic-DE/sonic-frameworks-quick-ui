/*
 *  SPDX-FileCopyrightText: 2026 Sandro Andrade <sandroandrade@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.BasicThemeDefinition {
    readonly property bool darkMode: Qt.styleHints.colorScheme === Qt.Dark

    readonly property color _controlBackgroundColor: darkMode ? palette.window : palette.base
    readonly property color _controlTextColor: darkMode ? "white" : palette.windowText
    readonly property color _highlightedTextColor: darkMode ? "white" : palette.highlightedText

    readonly property color _alternateBackgroundColor: darkMode
        ? _controlBackgroundColor
        : Qt.darker(_controlBackgroundColor, 1.05)

    readonly property color _viewAlternateBackgroundColor: darkMode
        ? _controlBackgroundColor
        : palette.alternateBase

    readonly property color _selectionAlternateBackgroundColor: Qt.darker(palette.highlight, 1.05)

    textColor: _controlTextColor
    disabledTextColor: disabledPalette.windowText

    highlightColor: palette.highlight
    highlightedTextColor: _highlightedTextColor

    backgroundColor: _controlBackgroundColor
    alternateBackgroundColor: _alternateBackgroundColor

    activeTextColor: _highlightedTextColor
    activeBackgroundColor: palette.highlight

    linkColor: "#2980B9"
    linkBackgroundColor: "#2980B9"
    visitedLinkColor: "#7F8C8D"
    visitedLinkBackgroundColor: "#7F8C8D"

    hoverColor: palette.highlight
    focusColor: palette.highlight

    negativeTextColor: "#DA4453"
    negativeBackgroundColor: "#DA4453"
    neutralTextColor: "#F67400"
    neutralBackgroundColor: "#F67400"
    positiveTextColor: "#27AE60"
    positiveBackgroundColor: "#27AE60"

    buttonTextColor: _controlTextColor
    buttonBackgroundColor: _controlBackgroundColor
    buttonAlternateBackgroundColor: _alternateBackgroundColor
    buttonHoverColor: palette.highlight
    buttonFocusColor: palette.highlight

    viewTextColor: _controlTextColor
    viewBackgroundColor: _controlBackgroundColor
    viewAlternateBackgroundColor: _viewAlternateBackgroundColor
    viewHoverColor: palette.highlight
    viewFocusColor: palette.highlight

    selectionTextColor: _highlightedTextColor
    selectionBackgroundColor: palette.highlight
    selectionAlternateBackgroundColor: _selectionAlternateBackgroundColor
    selectionHoverColor: palette.highlight
    selectionFocusColor: palette.highlight

    tooltipTextColor: _controlTextColor
    tooltipBackgroundColor: _controlBackgroundColor
    tooltipAlternateBackgroundColor: _alternateBackgroundColor
    tooltipHoverColor: palette.highlight
    tooltipFocusColor: palette.highlight

    complementaryTextColor: _controlTextColor
    complementaryBackgroundColor: _controlBackgroundColor
    complementaryAlternateBackgroundColor: _alternateBackgroundColor
    complementaryHoverColor: palette.highlight
    complementaryFocusColor: palette.highlight

    headerTextColor: _controlTextColor
    headerBackgroundColor: _controlBackgroundColor
    headerAlternateBackgroundColor: _alternateBackgroundColor
    headerHoverColor: palette.highlight
    headerFocusColor: palette.highlight

    defaultFont: fontMetrics.font

    property list<QtObject> children: [
        TextMetrics {
            id: fontMetrics
        },
        SystemPalette {
            id: palette
            colorGroup: SystemPalette.Active
        },
        SystemPalette {
            id: disabledPalette
            colorGroup: SystemPalette.Disabled
        }
    ]

    function __syncPalette(object) {
        if (!object || object.palette === undefined) {
            return;
        }

        const textColor = object.Kirigami.Theme.textColor;
        const backgroundColor = object.Kirigami.Theme.backgroundColor;
        const alternateBackgroundColor = object.Kirigami.Theme.alternateBackgroundColor;
        const highlightColor = object.Kirigami.Theme.highlightColor;
        const highlightedTextColor = object.Kirigami.Theme.highlightedTextColor;

        object.palette.windowText = textColor;
        object.palette.text = textColor;
        object.palette.buttonText = textColor;
        object.palette.brightText = textColor;

        object.palette.window = backgroundColor;
        object.palette.base = backgroundColor;
        object.palette.button = backgroundColor;
        object.palette.alternateBase = alternateBackgroundColor;

        object.palette.highlight = highlightColor;
        object.palette.highlightedText = highlightedTextColor;

        /*
         * Qt Quick Controls' iOS style appears to use these lower-level
         * palette roles for delegate/background rendering. In dark mode,
         * keep them aligned with Kirigami.Theme.backgroundColor so
         * ItemDelegate-based controls, such as GlobalDrawerActionItem, do
         * not get a mismatching darker background.
         *
         * In light mode, restore the native SystemPalette values.
         */
        object.palette.light = darkMode ? backgroundColor : palette.light;
        object.palette.midlight = darkMode ? backgroundColor : palette.midlight;
        object.palette.mid = darkMode ? backgroundColor : palette.mid;
        object.palette.dark = darkMode ? backgroundColor : palette.dark;
        object.palette.shadow = darkMode ? backgroundColor : palette.shadow;
    }

    onSync: object => {
        __syncPalette(object);
    }

    function __propagateColorSet(object, context) {
        __syncPalette(object);
    }

    function __propagateTextColor(object, color) {
        __syncPalette(object);
    }

    function __propagateBackgroundColor(object, color) {
        __syncPalette(object);
    }

    function __propagatePrimaryColor(object, color) {
        __syncPalette(object);
    }

    function __propagateAccentColor(object, color) {
        __syncPalette(object);
    }
}
