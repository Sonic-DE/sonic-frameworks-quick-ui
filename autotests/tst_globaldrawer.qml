/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import QtTest

// Inline components are needed because ApplicationItem and
// ApplicationWindow types expect themselves to be top-level components.
TestCase {
    name: "GlobalDrawerHeader"
    visible: true
    when: windowShown

    width: 500
    height: 500

    component AppItemComponent : Kirigami.ApplicationWindow {
        id: app

        property alias headerItem: headerItem
        property alias topItem: topItem
        property alias sidebarSizeItem: sidebarSizeItemDelegate

        width: 500
        height: 500
        visible: true

        globalDrawer: Kirigami.GlobalDrawer {
            drawerOpen: true

            header: Rectangle {
                id: headerItem
                implicitHeight: 50
                implicitWidth: 50
                color: "red"
                radius: 20 // to see its bounds
            }

            actions: [
                Kirigami.Action {
                    text: "View"
                    icon.name: "view-list-icons"
                    Kirigami.Action {
                        text: "action 1"
                    }
                    Kirigami.Action {
                        text: "action 2"
                    }
                    Kirigami.Action {
                        text: "action 3"
                    }
                },
                Kirigami.Action {
                    text: "Sync"
                    icon.name: "folder-sync"
                }
            ]

            topContent: [
                // Create some item which we can use to measure actual header height
                Rectangle {
                    id: topItem
                    Layout.fillWidth: true
                    implicitHeight: 60
                    color: "green"
                    radius: 20 // to see its bounds
                }
            ]
        }

        pageStack.initialPage: startPage
        Kirigami.Page {
            id: startPage
            QQC2.ItemDelegate {
                id: sidebarSizeItemDelegate
                icon.name: "go-back"
            }
        }
    }

    Component {
        id: pageComponent
        Kirigami.Page {
            title: "Layer 1"
        }
    }

    Component {
        id: appItemComponent
        AppItemComponent {}
    }

    function test_headerItemVisibility() {
        if (Qt.platform.os === "unix") {
            skip("On FreeBSD Qt 6.5 fails deep inside generated MOC code for `drawerOpen: true` binding");
        }
        const app = createTemporaryObject(appItemComponent, this);
        verify(app);
        const { headerItem } = app;
        app.globalDrawer.showHeaderWhenCollapsed = true;

        compare(app.globalDrawer.parent, app.T.Overlay.overlay);

        waitForRendering(app.globalDrawer.contentItem);

        verify(headerItem.height !== 0);

        const drawerLayout = app.globalDrawer.contentItem;
        const oldY = drawerLayout.contentItem.y;
        verify(oldY > 0);

        // With visible header the content item is lower than with invisible header.
        headerItem.visible = false;
        tryVerify(() => {
            return drawerLayout.contentItem.y < oldY;
        });

        // And now return it back to where we started.
        headerItem.visible = true;
        tryVerify(() => {
            return drawerLayout.contentItem.y === oldY;
        });
    }

    function test_paddingAppliedOnce() {
        const app = createTemporaryObject(appItemComponent, this);
        verify(app);

        const drawer = app.globalDrawer;
        drawer.width = 300;
        drawer.leftPadding = 0;
        drawer.topPadding = 0;
        drawer.rightPadding = 0;
        drawer.bottomPadding = 0;
        waitForRendering(drawer.contentItem);
        tryCompare(drawer.contentItem.anchors, "topMargin", 0);

        const initialLayoutPosition = drawer.contentItem.mapToItem(T.Overlay.overlay, 0, 0);
        const initialLayoutWidth = drawer.contentItem.width;
        const initialLayoutHeight = drawer.contentItem.height;

        const leftPadding = 20;
        const topPadding = 30;
        const rightPadding = 40;
        const bottomPadding = 50;
        drawer.leftPadding = leftPadding;
        drawer.topPadding = topPadding;
        drawer.rightPadding = rightPadding;
        drawer.bottomPadding = bottomPadding;

        tryVerify(() => {
            const paddedLayoutPosition = drawer.contentItem.mapToItem(T.Overlay.overlay, 0, 0);
            return Math.round(paddedLayoutPosition.x - initialLayoutPosition.x) === leftPadding
                && Math.round(paddedLayoutPosition.y - initialLayoutPosition.y) === topPadding
                && Math.round(initialLayoutWidth - drawer.contentItem.width) === leftPadding + rightPadding
                && Math.round(initialLayoutHeight - drawer.contentItem.height) === topPadding + bottomPadding;
        });
    }

    function test_topContentUsesImplicitHeight() {
        const app = createTemporaryObject(appItemComponent, this);
        verify(app);
        waitForRendering(app.globalDrawer.contentItem);

        compare(Math.round(app.topItem.parent.height), Math.round(app.topItem.parent.implicitHeight));
        compare(app.topItem.parent.Layout.leftMargin, 0);
        compare(app.topItem.parent.Layout.topMargin, 0);
        compare(app.topItem.parent.Layout.rightMargin, 0);
    }

    component AppItemLoaderComponent : Kirigami.ApplicationItem {
        globalDrawer: globalDrawerLoader.item
        contextDrawer: contextDrawerLoader.item

        Loader {
            id: globalDrawerLoader
            active: true
            sourceComponent: Kirigami.GlobalDrawer {}
        }
        Loader {
            id: contextDrawerLoader
            active: true
            sourceComponent: Kirigami.ContextDrawer {}
        }
    }

    Component {
        id: appItemLoaderComponent
        AppItemLoaderComponent {}
    }

    component AppWindowLoaderComponent : Kirigami.ApplicationWindow {
        globalDrawer: globalDrawerLoader.item
        contextDrawer: contextDrawerLoader.item

        Loader {
            id: globalDrawerLoader
            active: true
            sourceComponent: Kirigami.GlobalDrawer {}
        }
        Loader {
            id: contextDrawerLoader
            active: true
            sourceComponent: Kirigami.ContextDrawer {}
        }
    }

    Component {
        id: appWindowLoaderComponent
        AppWindowLoaderComponent {}
    }

    function test_reparentingFromLoader_data() {
        return [
            { tag: "item", component: appItemLoaderComponent },
            { tag: "window", component: appWindowLoaderComponent },
        ];
    }

    function test_reparentingFromLoader({ component }) {
        const app = createTemporaryObject(component, this);
        verify(app);

        compare(app.globalDrawer.parent, app.T.Overlay.overlay);
        compare(app.contextDrawer.parent, app.T.Overlay.overlay);
    }

    function test_collapsedColumnSize() {
        const app = createTemporaryObject(appItemComponent, this);
        verify(app);
        app.globalDrawer.open();
        app.globalDrawer.collapsible = true;
        app.globalDrawer.collapsed = true;
        tryVerify(() => {return app.globalDrawer.width == app.sidebarSizeItem.implicitWidth + app.globalDrawer.leftPadding + app.globalDrawer.rightPadding});
        verify(app.globalDrawer.width  > 0);
    }

    function test_pageRowSidebar() {
        const app = createTemporaryObject(appItemComponent, this);
        verify(app)
        compare(app.pageStack.columnView.x, 0);
        app.pageStack.leftSidebar = app.globalDrawer
        app.globalDrawer.modal = false;
        compare(app.pageStack.columnView.x, app.globalDrawer.width);
        verify(app.globalDrawer.visible);
        // Test basic show/hide
        app.globalDrawer.close();
        tryVerify(() => {return !app.globalDrawer.visible});
        app.globalDrawer.open();
        tryVerify(() => {return app.globalDrawer.visible});

        // When we push a new layer, the drawer must become invisible
        app.pageStack.layers.push(pageComponent);
        tryVerify(() => {return !app.globalDrawer.visible});
        // And get back visible on pop
        app.pageStack.layers.pop()
        tryVerify(() => {return app.globalDrawer.visible});

        // Push a layer with the drawer closed
        app.globalDrawer.close();
        tryVerify(() => {return !app.globalDrawer.visible});
        app.pageStack.layers.push(pageComponent);
        tryVerify(() => {return !app.globalDrawer.visible});

        // Opening it should stay invisible
        app.globalDrawer.open()
        tryVerify(() => {return !app.globalDrawer.visible});
        // But when popping it will become visible again as we asked for it
        app.pageStack.layers.pop()
        tryVerify(() => {return app.globalDrawer.visible});
    }
}
