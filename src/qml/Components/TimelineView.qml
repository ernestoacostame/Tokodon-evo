// SPDX-FileCopyrightText: 2024 Joshua Goins <josh@redstrate.com>
// SPDX-License-Identifier: GPL-3.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as Components
import org.kde.tokodon

import '..'
import '../PostDelegate'

ListView {
    id: root

    // Set to expand all of the posts in the list
    property bool expandedPost: false

    // Set to the original post URL to show the "show more replies" message
    property string originalPostUrl

    // Shows the post action in the bottom-right
    property bool showPostAction: true

    readonly property bool needsToShowBothActions: goToTopAction.visible && postAction.visible
    readonly property var singleActionToShow: {
        if (goToTopAction.visible) {
            return goToTopAction;
        }
        if (postAction.visible) {
            return postAction;
        }
        return null;
    }
    readonly property bool hasAnyActionToShow: singleActionToShow !== null

    // This causes jumping on the timeline. needs more investigation before it's re-enabled
    reuseItems: false

    // Call this function in Keys.onPressed to get PgUp/PgDn support
    function handleKeyEvent(event: KeyEvent): void {
        if (event.key === Qt.Key_PageUp && !root.atYBeginning) {
            event.accepted = true;
            root.contentY -= height;
        } else if (event.key === Qt.Key_PageDown && !root.atYEnd) {
            event.accepted = true;
            root.contentY += height;
        }
        if (event.accepted) {
            root.contentY = Math.min(Math.max(root.contentY, 0), root.contentHeight);
        }
    }

    // Used for pages like TimelinePage to control video playback
    property bool isCurrentPage: true

    Connections {
        target: root.model
        function onPostSourceReady(backend, isEdit): void {
            const item = applicationWindow().pageStack.pushDialogLayer(Qt.createComponent("org.kde.tokodon", "StatusComposer"), {
                purpose: isEdit ? StatusComposer.Edit : StatusComposer.Redraft,
                backend: backend
            }, {
                title: isEdit ? i18n("Edit Post") : i18n("Re-draft Post"),
                width: Kirigami.Units.gridUnit * 30,
                height: Kirigami.Units.gridUnit * 30,
                modality: Qt.NonModal
            });
            item.refreshData(); // to refresh spoiler text, etc
        }

        function onRepositionAt(index): void {
            root.positionViewAtIndex(index, ListView.Beginning);
        }

        function onStreamedPostAdded(id: string): void {
            // Update the read marker if we're at the top and a post just came in
            if (root.atYBeginning && root.model.updateReadMarker) {
                root.model.updateReadMarker(id);
            }
        }
    }

    readonly property Kirigami.Action postAction: Kirigami.Action {
        icon.name: "document-edit-symbolic"
        text: i18nc("@action:button", "Create Post")
        visible: root.showPostAction

        onTriggered: Navigation.openComposer("")
    }

    readonly property Kirigami.Action goToTopAction: Kirigami.Action {
        icon.name: "arrow-up-symbolic"
        text: i18nc("@info:tooltip", "Return to Top")
        visible: !root.atYBeginning

        onTriggered: root.positionViewAtBeginning()
    }

    // this is an empty item just meant for opacity layering
    // otherwise the opacity animation when switching between single/double is bad
    Item {
        anchors.fill: parent

        opacity: root.hasAnyActionToShow ? 1 : 0
        visible: opacity !== 0

        Behavior on opacity {
            NumberAnimation {}
        }

        Components.FloatingButton {
            id: singleFloatingButton
            anchors {
                right: parent.right
                rightMargin: Kirigami.Units.largeSpacing
                bottom: parent.bottom
                bottomMargin: Kirigami.Units.largeSpacing
            }

            visible: !root.needsToShowBothActions
            action: root.singleActionToShow
            icon.color: action === root.postAction ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

            background: Kirigami.ShadowedRectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
                radius: singleFloatingButton.radius

                shadow {
                    size: 10
                    xOffset: 0
                    yOffset: 2
                    color: Qt.rgba(0, 0, 0, 0.2)
                }

                border {
                    width: 1
                    color: if (singleFloatingButton.down || singleFloatingButton.visualFocus) {
                        Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.backgroundColor, 0.4)
                    } else if (singleFloatingButton.enabled && singleFloatingButton.hovered) {
                        Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.backgroundColor, 0.6)
                    } else {
                        Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast)
                    }
                }

                color: {
                    if (singleFloatingButton.action === root.postAction) {
                        if (singleFloatingButton.down || singleFloatingButton.visualFocus) {
                            return Kirigami.Theme.hoverColor;
                        } else if (singleFloatingButton.enabled && singleFloatingButton.hovered) {
                            return Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.highlightColor, 0.8);
                        } else {
                            return Kirigami.Theme.highlightColor;
                        }
                    } else {
                        if (singleFloatingButton.down || singleFloatingButton.visualFocus) {
                            return Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.backgroundColor, 0.6);
                        } else if (singleFloatingButton.enabled && singleFloatingButton.hovered) {
                            return Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.backgroundColor, 0.8);
                        } else {
                            return Kirigami.Theme.backgroundColor;
                        }
                    }
                }
            }
        }

        Kirigami.ShadowedRectangle {
            id: doubleFloatingButton
            anchors {
                right: parent.right
                rightMargin: Kirigami.Units.largeSpacing
                bottom: parent.bottom
                bottomMargin: Kirigami.Units.largeSpacing
            }

            visible: root.needsToShowBothActions

            radius: Kirigami.Units.largeSpacing
            color: Kirigami.Theme.backgroundColor

            readonly property real __padding: Kirigami.Settings.hasTransientTouchInput ? (Kirigami.Units.largeSpacing * 2) : Kirigami.Units.largeSpacing

            // Left for leading and right for trailing buttons
            function __radiusA(): real {
                return LayoutMirroring.enabled ? 0 : radius;
            }

            // and vice-versa
            function __radiusB(): real {
                return LayoutMirroring.enabled ? radius : 0;
            }

            implicitHeight: Math.max(leadingButton.implicitBackgroundHeight + leadingButton.topInset + leadingButton.bottomInset,
                                     leadingButton.implicitContentHeight + leadingButton.topPadding + leadingButton.bottomPadding)
            implicitWidth: 2 * implicitHeight - 1

            shadow {
                size: 10
                xOffset: 0
                yOffset: 2
                color: Qt.rgba(0, 0, 0, 0.2)
            }

            T.RoundButton {
                id: leadingButton

                LayoutMirroring.enabled: doubleFloatingButton.LayoutMirroring.enabled

                readonly property size __effectiveIconSize: Qt.size(
                    root.goToTopAction.icon.height > 0 ? root.goToTopAction.icon.height : Kirigami.Units.iconSizes.medium,
                    root.goToTopAction.icon.width > 0 ? root.goToTopAction.icon.width : Kirigami.Units.iconSizes.medium,
                )

                padding: doubleFloatingButton.__padding

                topPadding: padding
                leftPadding: padding
                rightPadding: padding
                bottomPadding: padding

                z: (down || visualFocus || (enabled && hovered)) ? 2 : 0

                background: Kirigami.ShadowedRectangle {
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Button

                    corners {
                        topLeftRadius: doubleFloatingButton.__radiusA()
                        bottomLeftRadius: doubleFloatingButton.__radiusA()
                        topRightRadius: doubleFloatingButton.__radiusB()
                        bottomRightRadius: doubleFloatingButton.__radiusB()
                    }

                    border {
                        width: 1
                        color: if (leadingButton.down || leadingButton.visualFocus) {
                            Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.backgroundColor, 0.4)
                        } else if (leadingButton.enabled && leadingButton.hovered) {
                            Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.backgroundColor, 0.6)
                        } else {
                            Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast)
                        }
                    }

                    color: if (leadingButton.down || leadingButton.visualFocus) {
                        Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.backgroundColor, 0.6)
                    } else if (leadingButton.enabled && leadingButton.hovered) {
                        Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.backgroundColor, 0.8)
                    } else {
                        Kirigami.Theme.backgroundColor
                    }
                }

                contentItem: Item {
                    implicitWidth: parent.__effectiveIconSize.width
                    implicitHeight: parent.__effectiveIconSize.height

                    Kirigami.Icon {
                        anchors.fill: parent
                        color: leadingButton.icon.color
                        source: root.goToTopAction.icon.name !== "" ? root.goToTopAction.icon.name : root.goToTopAction.icon.source
                    }
                }

                action: root.goToTopAction
                anchors.left: parent.left
                height: parent.height
                width: parent.height
                enabled: action ? action.enabled : false
                display: QQC2.AbstractButton.IconOnly
                QQC2.ToolTip.visible: hovered && QQC2.ToolTip.text.length > 0
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                QQC2.ToolTip.text: action.tooltip
            }

            T.RoundButton {
                id: trailingButton

                readonly property size __effectiveIconSize: Qt.size(
                    root.postAction.icon.height > 0 ? root.postAction.icon.height : Kirigami.Units.iconSizes.medium,
                    root.postAction.icon.width > 0 ? root.postAction.icon.width : Kirigami.Units.iconSizes.medium,
                )

                padding: doubleFloatingButton.__padding

                topPadding: padding
                leftPadding: padding
                rightPadding: padding
                bottomPadding: padding

                LayoutMirroring.enabled: doubleFloatingButton.LayoutMirroring.enabled

                z: (down || visualFocus || (enabled && hovered)) ? 2 : 0

                background: Kirigami.ShadowedRectangle {
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Button

                    corners {
                        topLeftRadius: doubleFloatingButton.__radiusB()
                        bottomLeftRadius: doubleFloatingButton.__radiusB()
                        topRightRadius: doubleFloatingButton.__radiusA()
                        bottomRightRadius: doubleFloatingButton.__radiusA()
                    }

                    border {
                        width: 1
                        color: if (trailingButton.down || trailingButton.visualFocus) {
                            Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.highlightColor, 0.4)
                        } else if (trailingButton.enabled && trailingButton.hovered) {
                            Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.highlightColor, 0.6)
                        } else {
                            Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.highlightColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast)
                        }
                    }

                    color: if (trailingButton.down || trailingButton.visualFocus) {
                        Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.highlightColor, 0.6)
                    } else if (trailingButton.enabled && trailingButton.hovered) {
                        Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.hoverColor, Kirigami.Theme.highlightColor, 0.8)
                    } else {
                        Kirigami.Theme.highlightColor
                    }
                }

                contentItem: Item {
                    implicitWidth: parent.__effectiveIconSize.width
                    implicitHeight: parent.__effectiveIconSize.height

                    Kirigami.Icon {
                        anchors.fill: parent
                        color: Kirigami.Theme.highlightedTextColor
                        source: root.postAction.icon.name !== "" ? root.postAction.icon.name : root.postAction.icon.source
                    }
                }

                action: root.postAction
                anchors.right: parent.right
                height: parent.height
                width: parent.height
                enabled: action ? action.enabled : false
                display: QQC2.AbstractButton.IconOnly
                QQC2.ToolTip.visible: hovered && QQC2.ToolTip.text.length > 0
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                QQC2.ToolTip.text: action.tooltip
            }
        }
    }

    Rectangle {
        anchors {
            fill: parent
            topMargin: root.headerItem ? root.headerItem.height : 0
        }

        visible: root.model.loading && root.count === 0

        color: Kirigami.Theme.backgroundColor

        Kirigami.LoadingPlaceholder {
            anchors.centerIn: parent
        }
    }

    footer: Kirigami.FlexColumn {
        id: flexColumn

        spacing: Kirigami.Units.largeSpacing

        padding: 0
        maximumWidth: Kirigami.Units.gridUnit * 40

        width: parent.width
        implicitHeight: Kirigami.Units.gridUnit * 4
        visible: ListView.view.count > 0

        Kirigami.Separator {
            Layout.fillWidth: true
            visible: endOfTimelineMessage.visible || loadingBar.visible
        }

        Kirigami.PlaceholderMessage {
            id: repliesNotAvailableMessage

            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: root.originalPostUrl.length !== 0
            text: i18nc("@info:status", "Some replies are not available")
            explanation: i18n("To view all replies, open the post on the original server.")
            helpfulAction: Kirigami.Action {
                icon.name: "open-link-symbolic"
                text: i18nc("@action:button 'Browser' being a web browser", "Open in Browser")
                onTriggered: Qt.openUrlExternally(root.originalPostUrl)
            }
        }

        Kirigami.PlaceholderMessage {
            id: endOfTimelineMessage

            visible: root.model.atEnd ?? false
            text: i18nc("@info:status No more posts to read", "No More Posts")

            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.largeSpacing * 2
            Layout.alignment: Qt.AlignHCenter
        }

        QQC2.ProgressBar {
            id: loadingBar

            visible: root.model.loading
            indeterminate: true

            Layout.alignment: Qt.AlignHCenter
        }
    }

    delegate: PostDelegate {
        id: status

        timelineModel: ListView.view.model
        expandedPost: root.expandedPost
        showSeparator: index !== ListView.view.count - 1
        loading: ListView.view.model.loading
        width: ListView.view.width

        Connections {
            target: status.ListView.view

            function onContentYChanged(): void {
                const aMin = status.y;
                const aMax = status.y + status.height;

                const bMin = status.ListView.view.contentY;
                const bMax = status.ListView.view.contentY + status.ListView.view.height;

                if (!root.isCurrentPage) {
                    status.inViewPort = false;
                    return;
                }

                let topEdgeVisible;
                let bottomEdgeVisible;

                // we are still checking two rectangles, but if one is bigger than the other
                // just switch which one should be checked.
                if (status.height > status.ListView.view.height) {
                    topEdgeVisible = bMin > aMin && bMin < aMax;
                    bottomEdgeVisible = bMax > aMin && bMax < aMax;
                } else {
                    topEdgeVisible = aMin > bMin && aMin < bMax;
                    bottomEdgeVisible = aMax > bMin && aMax < bMax;
                }

                status.inViewPort = topEdgeVisible || bottomEdgeVisible;
                if (status.inViewPort && status.ListView.view.model.updateReadMarker) {
                    status.ListView.view.model.updateReadMarker(status.originalId);
                }
            }
        }

        Connections {
            target: root

            function onIsCurrentPageChanged() {
                if (!root.isCurrentPage) {
                    status.inViewPort = false;
                } else {
                    status.ListView.view.contentYChanged();
                }
            }
        }

        Connections {
            target: applicationWindow()

            function onIsShowingFullScreenImageChanged(): void {
                if (applicationWindow().isShowingFullScreenImage) {
                    status.inViewPort = false;
                } else {
                    status.ListView.view.contentYChanged();
                }
            }
        }
    }
}
