// SPDX-FileCopyrightText: 2026 Joseph Crowell <joseph.w.crowell@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtTest
import org.kde.kirigami as Kirigami
import KirigamiTestUtils

// Theme.toolsArea, the tools area stacking rule, the window region and the window
// background; a theme without a tools area keeps the old look.
TestCase {
    id: testCase
    name: "ToolsArea"
    width: 400
    height: 300
    visible: true
    when: windowShown

    Item {
        id: headerTheme
        Kirigami.Theme.colorSet: Kirigami.Theme.Header
        Kirigami.Theme.inherit: false
    }

    Component {
        id: barsComponent
        Item {
            property alias menuBar: menuBar
            property alias toolBar: toolBar
            property alias lower: lower
            width: 400
            height: 300
            Kirigami.Theme.colorSet: Kirigami.Theme.Header
            Kirigami.Theme.inherit: false
            // A menu bar over a toolbar at the top, and a bar below a gap.
            Kirigami.ToolsAreaBackground {
                id: menuBar
                width: 400
                height: 20
            }
            Kirigami.ToolsAreaBackground {
                id: toolBar
                y: 20
                width: 400
                height: 30
            }
            Kirigami.ToolsAreaBackground {
                id: lower
                y: 100
                width: 400
                height: 30
            }
        }
    }

    Component {
        id: windowBackgroundComponent
        Item {
            width: 400
            height: 300
            Kirigami.ToolsAreaWindowBackground {
                anchors.fill: parent
                color: "red"
            }
            Kirigami.ToolsAreaBackground {
                width: 400
                height: 40
                separatorVisible: false
            }
        }
    }

    Component {
        id: applicationWindowComponent
        Kirigami.AbstractApplicationWindow {
            visible: false
        }
    }

    function test_applicationWindowColor() {
        const window = createTemporaryObject(applicationWindowComponent, testCase);
        verify(window.color.a > 0);
        verify(!window.background.visible);
        ToolsAreaControl.set(true, Qt.rgba(0, 0, 1, 0.5), Qt.rgba(0, 0, 1, 0.5), "#010203", true, true, true);
        compare(window.color.a, 0);
        verify(window.background.visible);
        compare(window.background.color, window.Kirigami.Theme.backgroundColor);
        // Opaque tools area: an ordinary window again.
        ToolsAreaControl.set(true, "blue", "blue", "#010203", true, true, false);
        verify(window.color.a > 0);
        verify(!window.background.visible);
    }

    function separatorOf(bar) {
        return findChild(bar, "toolsAreaSeparator");
    }

    function cleanup() {
        ToolsAreaControl.reset();
    }

    function test_defaults() {
        const toolsArea = Kirigami.Theme.toolsArea;
        verify(toolsArea);
        compare(toolsArea.active, false);
        verify(!toolsArea.backgroundColor.valid);
        verify(!toolsArea.separatorColor.valid);
        compare(toolsArea.blurBehind, false);
        compare(toolsArea.translucent, false);
    }

    function test_withoutToolsAreaLooksAsBefore() {
        const bars = createTemporaryObject(barsComponent, testCase);
        waitForRendering(bars);
        for (const bar of [bars.menuBar, bars.toolBar, bars.lower]) {
            verify(!bar.inToolsArea);
            compare(bar.color, headerTheme.Kirigami.Theme.backgroundColor);
            verify(separatorOf(bar).visible);
        }
        compare(ToolsAreaControl.regionOf(testCase.Window.window).length, 0);
    }

    function test_stackedBarsFormTheToolsArea() {
        ToolsAreaControl.set(true, Qt.rgba(0, 0, 1, 0.5), Qt.rgba(0, 1, 0, 0.5), "#010203", true, true, true);
        const bars = createTemporaryObject(barsComponent, testCase);
        tryVerify(() => bars.menuBar.inToolsArea && bars.toolBar.inToolsArea);
        verify(!bars.lower.inToolsArea);
        // One separator, under the lowest bar, in the tools area colour.
        verify(!separatorOf(bars.menuBar).visible);
        verify(separatorOf(bars.toolBar).visible);
        compare(separatorOf(bars.toolBar).color, Qt.color("#010203"));
        verify(separatorOf(bars.lower).visible);
        // The tools area background follows the window's activation.
        const expected = testCase.Window.active ? Qt.rgba(0, 0, 1, 0.5) : Qt.rgba(0, 1, 0, 0.5);
        compare(bars.menuBar.color, expected);
        compare(bars.lower.color, headerTheme.Kirigami.Theme.backgroundColor);

        const region = ToolsAreaControl.regionOf(testCase.Window.window);
        compare(region.length, 1);
        const origin = bars.mapToItem(null, 0, 0);
        compare(region[0], Qt.rect(origin.x, origin.y, 400, 50));
    }

    function test_settingsApplyLive() {
        const bars = createTemporaryObject(barsComponent, testCase);
        waitForRendering(bars);
        verify(!bars.menuBar.inToolsArea);
        ToolsAreaControl.set(true, Qt.rgba(0, 0, 1, 0.5), Qt.rgba(0, 0, 1, 0.5), "#010203", true, true, true);
        tryVerify(() => bars.menuBar.inToolsArea);
        compare(bars.menuBar.color, Qt.rgba(0, 0, 1, 0.5));
        ToolsAreaControl.reset();
        tryVerify(() => !bars.menuBar.inToolsArea);
        compare(bars.menuBar.color, headerTheme.Kirigami.Theme.backgroundColor);
        tryVerify(() => ToolsAreaControl.regionOf(testCase.Window.window).length === 0);
    }

    function test_windowBackgroundLeavesTheToolsAreaOut() {
        ToolsAreaControl.set(true, Qt.rgba(0, 0, 0, 0), Qt.rgba(0, 0, 0, 0), "#010203", true, true, true);
        const item = createTemporaryObject(windowBackgroundComponent, testCase);
        tryVerify(() => ToolsAreaControl.regionOf(testCase.Window.window).length === 1);
        waitForRendering(item);
        const image = grabImage(item);
        verify(!Qt.colorEqual(image.pixel(10, 10), "red"));
        verify(Qt.colorEqual(image.pixel(10, 100), "red"));
    }
}
