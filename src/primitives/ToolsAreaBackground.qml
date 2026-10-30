/*
 *  SPDX-FileCopyrightText: 2026 Joseph Crowell <joseph.w.crowell@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami.platform as Platform

/*!
  \qmltype ToolsAreaBackground
  \inqmlmodule org.kde.kirigami.primitives

  \brief The background of a toolbar or main menu bar, joining the window's tools area
  when it is part of the stack of bars at the window's top.

  When the theme uses a tools area (Theme.toolsArea.active) and the bar is in it, it
  draws the tools area background (translucent with blur behind if the theme says so,
  opaque in a maximized window when asked), and only the lowest bar draws the separator,
  in the tools area separator color. Otherwise it is the inherited color set's
  background with the usual separator, as bars have always looked (set the Header
  color set on the bar, as headers do). Only the bar's background:
  controls on the bar keep their own styling. Everything follows the theme live.
 */
Rectangle {
    id: root

    /*!
      Whether the bar may join the tools area (false for footers, for example).
     */
    property bool toolsAreaCandidate: true

    /*!
      Whether to draw the separator.
     */
    property bool separatorVisible: true

    /*!
      The edge the separator is drawn along outside the tools area: Qt.BottomEdge
      (default) or Qt.TopEdge. In the tools area it is always the bottom.
     */
    property int separatorEdge: Qt.BottomEdge

    /*!
      Whether the bar is drawn as part of the window's tools area.
     */
    readonly property bool inToolsArea: __toolsArea.active && region.inToolsArea

    /*!
      The separator item (for paddings that make room for it).
     */
    readonly property Item separator: separator

    readonly property Platform.ToolsArea __toolsArea: Platform.Theme.toolsArea
    readonly property bool __maximized: Window.visibility === Window.Maximized || Window.visibility === Window.FullScreen
    readonly property color __toolsAreaColor: Window.active ? __toolsArea.backgroundColor : __toolsArea.inactiveBackgroundColor

    color: {
        const base = inToolsArea && __toolsAreaColor.valid ? __toolsAreaColor : Platform.Theme.backgroundColor;
        return inToolsArea && __toolsArea.opaqueWhenMaximized && __maximized ? Qt.rgba(base.r, base.g, base.b, 1) : base;
    }

    Platform.ToolsAreaRegion {
        id: region
        anchors.fill: parent
        visible: root.toolsAreaCandidate && root.__toolsArea.active
    }

    Separator {
        id: separator
        objectName: "toolsAreaSeparator"
        visible: root.separatorVisible && (!root.inToolsArea || region.bottomOfToolsArea)
        anchors {
            left: parent.left
            right: parent.right
        }
        y: !root.inToolsArea && root.separatorEdge === Qt.TopEdge ? 0 : root.height - height
    }
    Binding {
        target: separator
        property: "color"
        value: root.__toolsArea.separatorColor
        when: root.inToolsArea && root.__toolsArea.separatorColor.valid
        restoreMode: Binding.RestoreBindingOrValue
    }
}
