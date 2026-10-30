/*
 *  SPDX-FileCopyrightText: 2026 Joseph Crowell <joseph.w.crowell@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef KIRIGAMI_TOOLSAREA_H
#define KIRIGAMI_TOOLSAREA_H

#include <QColor>
#include <QObject>
#include <QPointer>
#include <QQuickItem>
#include <QRegion>
#include <qqmlregistration.h>

#include "kirigamiplatform_export.h"

namespace Kirigami {
namespace Platform {

    /*!
     * \qmltype ToolsArea
     * \inqmlmodule org.kde.kirigami.platform
     * \nativetype Kirigami::Platform::ToolsArea
     *
     * \brief How the window's tools area is drawn: the toolbars and main menu bar at the
     * top of a window, under the title bar.
     *
     * Reached as \c Theme.toolsArea. The platform plugin fills it; the backgrounds of
     * toolbars and main menu bars in the window header use it, together with the Header
     * color set. Controls on those bars are not affected.
     */
    class KIRIGAMIPLATFORM_EXPORT ToolsArea : public QObject {
        Q_OBJECT
        QML_ELEMENT
        QML_UNCREATABLE("Reached as Theme.toolsArea")

        /*!
         * \qmlproperty bool ToolsArea::active
         * Whether the theme uses a tools area. While false, bars look as they always have.
         */
        Q_PROPERTY(bool active READ isActive NOTIFY changed FINAL)
        /*!
         * \qmlproperty color ToolsArea::backgroundColor
         * The tools area background in an active window (may be translucent); invalid when
         * the platform gives none, in which case the Header color set's background is used.
         */
        Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY changed FINAL)
        /*!
         * \qmlproperty color ToolsArea::inactiveBackgroundColor
         * The tools area background in an inactive window; invalid when the platform gives
         * none.
         */
        Q_PROPERTY(QColor inactiveBackgroundColor READ inactiveBackgroundColor NOTIFY changed FINAL)
        /*!
         * \qmlproperty color ToolsArea::separatorColor
         * The color of the line under the tools area; invalid when the platform gives none,
         * in which case the usual Separator color is used.
         */
        Q_PROPERTY(QColor separatorColor READ separatorColor NOTIFY changed FINAL)
        /*!
         * \qmlproperty bool ToolsArea::blurBehind
         * Whether a translucent tools area background blurs what is behind the window.
         */
        Q_PROPERTY(bool blurBehind READ blurBehind NOTIFY changed FINAL)
        /*!
         * \qmlproperty bool ToolsArea::opaqueWhenMaximized
         * Whether the tools area background is drawn opaque in a maximized or full screen
         * window.
         */
        Q_PROPERTY(bool opaqueWhenMaximized READ opaqueWhenMaximized NOTIFY changed FINAL)
        /*!
         * \qmlproperty bool ToolsArea::titleBarHidden
         * Whether the window decoration hides the title bar above the tools area.
         */
        Q_PROPERTY(bool titleBarHidden READ titleBarHidden NOTIFY changed FINAL)
        /*!
         * \qmlproperty bool ToolsArea::translucent
         * Whether windows are created with an alpha channel so a translucent tools area
         * shows what is behind the window. Application windows then paint their background
         * only outside the tools area (ToolsAreaWindowBackground).
         */
        Q_PROPERTY(bool translucent READ translucent NOTIFY changed FINAL)

    public:
        // The one instance every Theme returns.
        static ToolsArea* instance();

        bool isActive() const;
        QColor backgroundColor() const;
        QColor inactiveBackgroundColor() const;
        QColor separatorColor() const;
        bool blurBehind() const;
        bool opaqueWhenMaximized() const;
        bool titleBarHidden() const;
        bool translucent() const;

        // For platform plugins.
        void setActive(bool active);
        void setBackgroundColors(const QColor& active, const QColor& inactive);
        void setSeparatorColor(const QColor& color);
        void setBlurBehind(bool blur);
        void setOpaqueWhenMaximized(bool opaque);
        void setTitleBarHidden(bool hidden);
        void setTranslucent(bool translucent);

        // The union of a window's ToolsAreaRegions, in window coordinates.
        static QRegion region(const QQuickWindow* window);

    Q_SIGNALS:
        void changed();
        void regionChanged(QQuickWindow* window);

    private:
        explicit ToolsArea(QObject* parent = nullptr);

        bool m_active = false;
        QColor m_backgroundColor;
        QColor m_inactiveBackgroundColor;
        QColor m_separatorColor;
        bool m_blurBehind = false;
        bool m_opaqueWhenMaximized = false;
        bool m_titleBarHidden = false;
        bool m_translucent = false;
    };

    /*!
     * \qmltype ToolsAreaRegion
     * \inqmlmodule org.kde.kirigami.platform
     * \nativetype Kirigami::Platform::ToolsAreaRegion
     *
     * \brief Marks its area as part of the window's tools area, for blur behind it.
     *
     * Put one in the background of a toolbar or main menu bar. The window's tools area is
     * the stack of visible regions that starts at the window's top edge, as Silver's
     * toolsAreaRect spans the menu bar and top toolbars; a region below a gap isn't part
     * of it. The tools area is set as the window's \c _sonic_tools_area_region property (a
     * QRegion in window coordinates), which the platform uses to blur behind it.
     */
    class KIRIGAMIPLATFORM_EXPORT ToolsAreaRegion : public QQuickItem {
        Q_OBJECT
        QML_ELEMENT

        /*!
         * \qmlproperty bool ToolsAreaRegion::inToolsArea
         * Whether this region is part of its window's tools area.
         */
        Q_PROPERTY(bool inToolsArea READ inToolsArea NOTIFY inToolsAreaChanged FINAL)
        /*!
         * \qmlproperty bool ToolsAreaRegion::bottomOfToolsArea
         * Whether this region is the lowest in its window's tools area, where the tools
         * area separator is drawn.
         */
        Q_PROPERTY(bool bottomOfToolsArea READ bottomOfToolsArea NOTIFY inToolsAreaChanged FINAL)

    public:
        explicit ToolsAreaRegion(QQuickItem* parent = nullptr);
        ~ToolsAreaRegion() override;

        bool inToolsArea() const;
        bool bottomOfToolsArea() const;
        // Called by the registry.
        void setInToolsArea(bool in, bool bottom);

    Q_SIGNALS:
        void inToolsAreaChanged();

    protected:
        void itemChange(ItemChange change, const ItemChangeData& value) override;

    private:
        void attach(QQuickWindow* window);
        void update();

        QPointer<QQuickWindow> m_window;
        QRect m_rect;
        bool m_inToolsArea = false;
        bool m_bottomOfToolsArea = false;
    };

    /*!
     * \qmltype ToolsAreaWindowBackground
     * \inqmlmodule org.kde.kirigami.platform
     * \nativetype Kirigami::Platform::ToolsAreaWindowBackground
     *
     * \brief An application window's background with the tools area left out.
     *
     * Fills its window with \l color except the window's ToolsAreaRegions, as Silver paints
     * widget main windows: with a translucent tools area the window color is transparent
     * and the tools area shows only its own background.
     */
    class KIRIGAMIPLATFORM_EXPORT ToolsAreaWindowBackground : public QQuickItem {
        Q_OBJECT
        QML_ELEMENT

        /*!
         * \qmlproperty color ToolsAreaWindowBackground::color
         */
        Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged FINAL)

    public:
        explicit ToolsAreaWindowBackground(QQuickItem* parent = nullptr);

        QColor color() const;
        void setColor(const QColor& color);

    Q_SIGNALS:
        void colorChanged();

    protected:
        QSGNode* updatePaintNode(QSGNode* node, UpdatePaintNodeData* data) override;
        void itemChange(ItemChange change, const ItemChangeData& value) override;
        void geometryChange(const QRectF& newGeometry, const QRectF& oldGeometry) override;

    private:
        QColor m_color;
    };

}
}

#endif
