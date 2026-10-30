/*
 *  SPDX-FileCopyrightText: 2026 Joseph Crowell <joseph.w.crowell@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "toolsarea.h"
#include "kirigamiplatform_logging.h"

#include <QHash>
#include <QQuickWindow>
#include <QRegion>
#include <QSGRectangleNode>

#include <algorithm>

namespace Kirigami {
namespace Platform {

    namespace {
        // Each window's visible regions, by the item that reported them.
        QHash<QQuickWindow*, QHash<ToolsAreaRegion*, QRect>>& regions()
        {
            static QHash<QQuickWindow*, QHash<ToolsAreaRegion*, QRect>> s_regions;
            return s_regions;
        }

        // The regions in the window's tools area: those stacked from the top edge without a gap.
        QList<ToolsAreaRegion*> toolsAreaOf(QQuickWindow* window)
        {
            QList<std::pair<ToolsAreaRegion*, QRect>> sorted;
            const auto all = regions().value(window);
            for (auto it = all.cbegin(); it != all.cend(); ++it) {
                sorted.append({it.key(), it.value()});
            }
            std::sort(sorted.begin(), sorted.end(), [](const auto& a, const auto& b) {
                return a.second.top() < b.second.top();
            });
            QList<ToolsAreaRegion*> in;
            int bottom = 0;
            for (const auto& [item, rect] : std::as_const(sorted)) {
                if (rect.top() > bottom) {
                    break;
                }
                in.append(item);
                bottom = std::max(bottom, rect.bottom() + 1);
            }
            return in;
        }

        void publishRegion(QQuickWindow* window)
        {
            const QList<ToolsAreaRegion*> in = toolsAreaOf(window);
            const auto all = regions().value(window);
            // The lowest: the largest bottom edge (the first such, by stacking order).
            ToolsAreaRegion* bottom = nullptr;
            for (ToolsAreaRegion* item : in) {
                if (!bottom || all.value(item).bottom() > all.value(bottom).bottom()) {
                    bottom = item;
                }
            }
            for (ToolsAreaRegion* item : all.keys()) {
                item->setInToolsArea(in.contains(item), item == bottom);
            }
            const QRegion region = ToolsArea::region(window);
            const QVariant value = region.isEmpty() ? QVariant() : QVariant::fromValue(region);
            if (window->property("_sonic_tools_area_region") != value) {
                window->setProperty("_sonic_tools_area_region", value);
                qCDebug(KirigamiPlatform) << "Tools area region" << window << region.boundingRect();
                Q_EMIT ToolsArea::instance()->regionChanged(window);
            }
        }
    }

    QRegion ToolsArea::region(const QQuickWindow* window)
    {
        auto* key = const_cast<QQuickWindow*>(window);
        const auto all = regions().value(key);
        QRegion region;
        for (ToolsAreaRegion* item : toolsAreaOf(key)) {
            region += all.value(item);
        }
        return region;
    }

    ToolsArea::ToolsArea(QObject* parent)
        : QObject(parent)
    {
    }

    ToolsArea* ToolsArea::instance()
    {
        static ToolsArea* s_instance = new ToolsArea;
        return s_instance;
    }

    bool ToolsArea::isActive() const
    {
        return m_active;
    }

    void ToolsArea::setActive(bool active)
    {
        if (m_active != active) {
            m_active = active;
            Q_EMIT changed();
        }
    }

    QColor ToolsArea::backgroundColor() const
    {
        return m_backgroundColor;
    }

    QColor ToolsArea::inactiveBackgroundColor() const
    {
        return m_inactiveBackgroundColor;
    }

    QColor ToolsArea::separatorColor() const
    {
        return m_separatorColor;
    }

    bool ToolsArea::blurBehind() const
    {
        return m_blurBehind;
    }

    bool ToolsArea::opaqueWhenMaximized() const
    {
        return m_opaqueWhenMaximized;
    }

    bool ToolsArea::titleBarHidden() const
    {
        return m_titleBarHidden;
    }

    bool ToolsArea::translucent() const
    {
        return m_translucent;
    }

    void ToolsArea::setBackgroundColors(const QColor& active, const QColor& inactive)
    {
        if (m_backgroundColor != active || m_inactiveBackgroundColor != inactive) {
            m_backgroundColor = active;
            m_inactiveBackgroundColor = inactive;
            Q_EMIT changed();
        }
    }

    void ToolsArea::setSeparatorColor(const QColor& color)
    {
        if (m_separatorColor != color) {
            m_separatorColor = color;
            Q_EMIT changed();
        }
    }

    void ToolsArea::setBlurBehind(bool blur)
    {
        if (m_blurBehind != blur) {
            m_blurBehind = blur;
            Q_EMIT changed();
        }
    }

    void ToolsArea::setOpaqueWhenMaximized(bool opaque)
    {
        if (m_opaqueWhenMaximized != opaque) {
            m_opaqueWhenMaximized = opaque;
            Q_EMIT changed();
        }
    }

    void ToolsArea::setTitleBarHidden(bool hidden)
    {
        if (m_titleBarHidden != hidden) {
            m_titleBarHidden = hidden;
            Q_EMIT changed();
        }
    }

    void ToolsArea::setTranslucent(bool translucent)
    {
        if (m_translucent != translucent) {
            m_translucent = translucent;
            Q_EMIT changed();
        }
    }

    ToolsAreaRegion::ToolsAreaRegion(QQuickItem* parent)
        : QQuickItem(parent)
    {
    }

    ToolsAreaRegion::~ToolsAreaRegion()
    {
        attach(nullptr);
    }

    bool ToolsAreaRegion::inToolsArea() const
    {
        return m_inToolsArea;
    }

    bool ToolsAreaRegion::bottomOfToolsArea() const
    {
        return m_bottomOfToolsArea;
    }

    void ToolsAreaRegion::setInToolsArea(bool in, bool bottom)
    {
        if (m_inToolsArea != in || m_bottomOfToolsArea != bottom) {
            m_inToolsArea = in;
            m_bottomOfToolsArea = bottom;
            Q_EMIT inToolsAreaChanged();
        }
    }

    void ToolsAreaRegion::itemChange(ItemChange change, const ItemChangeData& value)
    {
        switch (change) {
        case ItemSceneChange:
            attach(value.window);
            break;
        case ItemVisibleHasChanged:
            update();
            break;
        default:
            break;
        }
        QQuickItem::itemChange(change, value);
    }

    void ToolsAreaRegion::attach(QQuickWindow* window)
    {
        if (m_window) {
            disconnect(m_window, nullptr, this, nullptr);
            auto it = regions().find(m_window);
            if (it != regions().end()) {
                it->remove(this);
                if (it->isEmpty()) {
                    regions().erase(it);
                }
                publishRegion(m_window);
            }
        }
        m_window = window;
        m_rect = QRect();
        setInToolsArea(false, false);
        if (m_window) {
            // Once per frame: ancestors moving or resizing don't notify this item.
            connect(m_window, &QQuickWindow::afterAnimating, this, &ToolsAreaRegion::update);
            update();
        }
    }

    void ToolsAreaRegion::update()
    {
        if (!m_window) {
            return;
        }
        const QRect rect = isVisible() ? mapRectToScene(boundingRect()).toAlignedRect() : QRect();
        const bool registered = regions().value(m_window).contains(this);
        if (rect == m_rect && registered == !rect.isEmpty()) {
            return;
        }
        m_rect = rect;
        if (rect.isEmpty()) {
            regions()[m_window].remove(this);
        } else {
            regions()[m_window].insert(this, rect);
        }
        publishRegion(m_window);
    }

    ToolsAreaWindowBackground::ToolsAreaWindowBackground(QQuickItem* parent)
        : QQuickItem(parent)
    {
        setFlag(ItemHasContents);
        connect(ToolsArea::instance(), &ToolsArea::regionChanged, this, [this](QQuickWindow* window) {
            if (window == QQuickItem::window()) {
                QQuickItem::update();
            }
        });
    }

    QColor ToolsAreaWindowBackground::color() const
    {
        return m_color;
    }

    void ToolsAreaWindowBackground::setColor(const QColor& color)
    {
        if (m_color != color) {
            m_color = color;
            QQuickItem::update();
            Q_EMIT colorChanged();
        }
    }

    void ToolsAreaWindowBackground::itemChange(ItemChange change, const ItemChangeData& value)
    {
        if (change == ItemSceneChange) {
            QQuickItem::update();
        }
        QQuickItem::itemChange(change, value);
    }

    void ToolsAreaWindowBackground::geometryChange(const QRectF& newGeometry, const QRectF& oldGeometry)
    {
        QQuickItem::geometryChange(newGeometry, oldGeometry);
        QQuickItem::update();
    }

    QSGNode* ToolsAreaWindowBackground::updatePaintNode(QSGNode* node, UpdatePaintNodeData*)
    {
        delete node;
        if (!window() || !m_color.isValid() || m_color.alpha() == 0) {
            return nullptr;
        }
        // The item's rectangle less the tools area, in this item's coordinates.
        const QRect own = boundingRect().toAlignedRect();
        const QPoint offset = mapToScene(QPointF(0, 0)).toPoint();
        const QRegion area = QRegion(own) - ToolsArea::region(window()).translated(-offset);
        auto* root = new QSGNode;
        for (const QRect& rect : area) {
            auto* fill = window()->createRectangleNode();
            fill->setRect(rect);
            fill->setColor(m_color);
            root->appendChildNode(fill);
        }
        return root;
    }

}
}

#include "moc_toolsarea.cpp"
