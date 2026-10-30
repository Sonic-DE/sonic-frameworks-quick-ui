// SPDX-FileCopyrightText: 2026 Joseph Crowell <joseph.w.crowell@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "toolsareacontrol.h"

#include "toolsarea.h"

#include <QQuickWindow>
#include <QRegion>

using Kirigami::Platform::ToolsArea;

ToolsAreaControl::ToolsAreaControl(QObject* parent)
    : QObject(parent)
{
}

void ToolsAreaControl::set(bool active,
    const QColor& background,
    const QColor& inactiveBackground,
    const QColor& separator,
    bool blurBehind,
    bool opaqueWhenMaximized,
    bool translucent)
{
    ToolsArea* toolsArea = ToolsArea::instance();
    toolsArea->setActive(active);
    toolsArea->setBackgroundColors(background, inactiveBackground);
    toolsArea->setSeparatorColor(separator);
    toolsArea->setBlurBehind(blurBehind);
    toolsArea->setOpaqueWhenMaximized(opaqueWhenMaximized);
    toolsArea->setTranslucent(translucent);
}

void ToolsAreaControl::reset()
{
    set(false, QColor(), QColor(), QColor(), false, false, false);
}

QVariantList ToolsAreaControl::regionOf(QQuickWindow* window) const
{
    QVariantList rects;
    for (const QRect& rect : window->property("_sonic_tools_area_region").value<QRegion>()) {
        rects.append(rect);
    }
    return rects;
}
