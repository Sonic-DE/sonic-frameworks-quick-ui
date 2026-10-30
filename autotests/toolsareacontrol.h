// SPDX-FileCopyrightText: 2026 Joseph Crowell <joseph.w.crowell@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QColor>
#include <QObject>
#include <QQuickWindow>
#include <QVariantList>
#include <qqmlregistration.h>

// Plays the platform plugin's part for the ToolsArea tests.
class ToolsAreaControl : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit ToolsAreaControl(QObject* parent = nullptr);

    Q_INVOKABLE void set(bool active,
        const QColor& background,
        const QColor& inactiveBackground,
        const QColor& separator,
        bool blurBehind,
        bool opaqueWhenMaximized,
        bool translucent);
    Q_INVOKABLE void reset();
    // The window's _sonic_tools_area_region as a list of rects.
    Q_INVOKABLE QVariantList regionOf(QQuickWindow* window) const;
};
