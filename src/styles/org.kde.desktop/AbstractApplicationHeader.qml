/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.kirigami.templates as T

T.AbstractApplicationHeader {
    id: root

    // Always use header bg color for toolbar (if available), even if the page
    // it's located on uses a different color set
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Header

    // Part of the window's tools area when stacked at the window's top.
    background: Kirigami.ToolsAreaBackground {
        separatorVisible: root.separatorVisible && (!root.page || !root.page.header || !root.page.header.visible || root.page.header.toString().indexOf("ToolBar") === -1)
        separatorEdge: root.y <= 0 ? Qt.BottomEdge : Qt.TopEdge
    }
}
