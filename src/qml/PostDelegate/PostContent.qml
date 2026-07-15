// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-FileCopyrightText: 2023 Joshua Goins <josh@redstrate.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.tokodon


// This is the main text content of a status
Item {
    id: root

    required property string content
    required property bool expandedPost
    required property bool secondary
    required property bool shouldOpenInternalLinks
    property bool selected: false
    property bool shouldOpenAnyLinks: true
    property bool hoverEnabled: true

    readonly property string hoveredLink: root.selected ? textArea.hoveredLink : label.hoveredLink

    Layout.fillWidth: true
    implicitWidth: root.selected ? textArea.implicitWidth : label.implicitWidth
    implicitHeight: root.selected ? textArea.implicitHeight : label.implicitHeight

    Accessible.name: i18nc("@info", "Post content")
    Accessible.description: TextHandler.stripHtml(root.content)

    activeFocusOnTab: true

    QQC2.Label {
        id: label
        visible: !root.selected
        anchors.fill: parent

        topPadding: 0
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0
        property string clickedUrl: ""

        text: TextHandler.fixBidirectionality(root.content, Config.defaultFont)
        textFormat: TextEdit.RichText
        wrapMode: TextEdit.Wrap
        color: root.secondary ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor

        onHoveredLinkChanged: if (hoveredLink.length > 0) {
            applicationWindow().hoverLinkIndicator.text = hoveredLink;
        } else {
            applicationWindow().hoverLinkIndicator.text = "";
        }

        TapHandler {
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            exclusiveSignals: TapHandler.SingleTap | TapHandler.DoubleTap
            // Exclude touchscreen users from this menu until we can figure out a better UX.
            // Currently it's way too easy to trigger this when tapping URLs.
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus

            onSingleTapped: (eventPoint, button) => {
                const point = label.mapFromGlobal(eventPoint.globalPosition.x, eventPoint.globalPosition.y);
                const foundLink = label.linkAt(point.x, point.y);
                if (!foundLink) {
                    return;
                }

                if (button === Qt.LeftButton) {
                    if (root.shouldOpenAnyLinks) {
                        applicationWindow().navigateLink(foundLink, root.shouldOpenInternalLinks)
                    }
                    return;
                }

                // Don't allow opening the menu for internal links, it doesn't make any sense as the user can't do anthing with it.
                const internalLink = foundLink.startsWith('hashtag:/') || foundLink.startsWith('account:/');
                if (button === Qt.RightButton && internalLink) {
                    return;
                }

                const linkMenuComponent = Qt.createComponent("org.kde.tokodon", "LinkMenu");
                const linkMenu = linkMenuComponent.createObject(label.QQC2.Overlay.overlay, {
                    url: foundLink,
                });

                (linkMenu as LinkMenu)?.popup(label.QQC2.ApplicationWindow.window);
            }
        }

        HoverHandler {
            enabled: root.hoverEnabled
            cursorShape: label.hoveredLink !== '' ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    QQC2.TextArea {
        id: textArea
        visible: root.selected
        anchors.fill: parent

        topPadding: 0
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0
        property string clickedUrl: ""

        text: TextHandler.fixBidirectionality(root.content, Config.defaultFont)
        textFormat: TextEdit.RichText
        wrapMode: TextEdit.Wrap
        color: root.secondary ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
        readOnly: true
        selectByMouse: true
        background: null

        onHoveredLinkChanged: if (hoveredLink.length > 0) {
            applicationWindow().hoverLinkIndicator.text = hoveredLink;
        } else {
            applicationWindow().hoverLinkIndicator.text = "";
        }

        TapHandler {
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            exclusiveSignals: TapHandler.SingleTap | TapHandler.DoubleTap
            // Exclude touchscreen users from this menu until we can figure out a better UX.
            // Currently it's way too easy to trigger this when tapping URLs.
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus

            onSingleTapped: (eventPoint, button) => {
                const point = textArea.mapFromGlobal(eventPoint.globalPosition.x, eventPoint.globalPosition.y);
                const foundLink = textArea.linkAt(point.x, point.y);
                if (!foundLink) {
                    return;
                }

                if (button === Qt.LeftButton) {
                    if (root.shouldOpenAnyLinks) {
                        applicationWindow().navigateLink(foundLink, root.shouldOpenInternalLinks)
                    }
                    return;
                }

                // Don't allow opening the menu for internal links, it doesn't make any sense as the user can't do anthing with it.
                const internalLink = foundLink.startsWith('hashtag:/') || foundLink.startsWith('account:/');
                if (button === Qt.RightButton && internalLink) {
                    return;
                }

                const linkMenuComponent = Qt.createComponent("org.kde.tokodon", "LinkMenu");
                const linkMenu = linkMenuComponent.createObject(textArea.QQC2.Overlay.overlay, {
                    url: foundLink,
                });

                (linkMenu as LinkMenu)?.popup(textArea.QQC2.ApplicationWindow.window);
            }
        }

        HoverHandler {
            enabled: root.hoverEnabled
            cursorShape: textArea.hoveredLink !== '' ? Qt.PointingHandCursor : Qt.IBeamCursor
        }
    }
}
