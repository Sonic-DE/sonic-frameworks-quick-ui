/*
 *  SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Effects as Effects

QQC2.Label {
    layer.effect: Effects.MultiEffect {
        shadowEnabled: true
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 1
        shadowBlur: 1
        blurMax: 4
        shadowScale: 1
        shadowColor: "black"
    }
}
