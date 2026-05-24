// SPDX-FileCopyrightText: 2022 Tobias Fella <fella@posteo.de>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.delegates as Delegates
import org.kde.kirigamiaddons.labs.components as KirigamiComponents
import org.kde.kirigamiaddons.statefulapp as StatefulApp

import org.kde.tokodon

QQC2.Pane {
    id: root

    required property TokodonApplication application
    // NOTE: we can't specify Sidebar here explicitly or else it becomes a cyclic dependency
    required property var sidebar
    readonly property Kirigami.PageRow pageStack: QQC2.ApplicationWindow.window ? (QQC2.ApplicationWindow.window as Main).pageStack : null

    visible: AccountManager.selectedAccount
    padding: 0

    function openAccountPage() {
        // There's no way we can open the page if the account isn't working
        if (AccountManager.selectedAccountHasIssue) {
            return;
        }

        const accountId = AccountManager.selectedAccountId;
        if (!root.pageStack.currentItem.model || !root.pageStack.currentItem.model.accountId || accountId !== root.pageStack.currentItem.accountId) {
            Navigation.openAccount(accountId);
        }
    }

    contentItem: ColumnLayout {
        id: content

        spacing: 0

        Delegates.RoundedItemDelegate {
            id: currentAccountDelegate

            readonly property string name: {
                if (!AccountManager.selectedAccount) {
                    return '';
                }

                if (AccountManager.selectedAccount.identity.displayNameHtml.length !== 0) {
                    return AccountManager.selectedAccount.identity.displayNameHtml;
                }

                return AccountManager.selectedAccount.username;
            }

            text: name

            onClicked: {
                root.openAccountPage()
                if (root.sidebar.modal) {
                    root.sidebar.close();
                }
            }
            Layout.fillWidth: true
            padding: root.sidebar.isCollapsed ? 0 : Kirigami.Units.largeSpacing

            contentItem: RowLayout {
                spacing: root.sidebar.isCollapsed ? 0 : Kirigami.Units.smallSpacing

                Item {
                    visible: root.sidebar.isCollapsed
                    Layout.fillWidth: true
                }

                QQC2.AbstractButton {
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.leftMargin: root.sidebar.isCollapsed ? 0 : Kirigami.Units.smallSpacing
                    Layout.rightMargin: root.sidebar.isCollapsed ? 0 : Kirigami.Units.smallSpacing

                    contentItem: KirigamiComponents.Avatar {
                        name: currentAccountDelegate.name
                        source: AccountManager.selectedAccount ? AccountManager.selectedAccount.identity.avatarUrl : ''
                    }

                    onClicked: root.openAccountPage()
                }

                Item {
                    visible: root.sidebar.isCollapsed
                    Layout.fillWidth: true
                }

                Delegates.SubtitleContentItem {
                    visible: !root.sidebar.isCollapsed
                    subtitle: AccountManager.selectedAccount ? '@' + AccountManager.selectedAccount.username : ''
                    subtitleItem.textFormat: Text.PlainText
                    itemDelegate: currentAccountDelegate
                    Layout.fillWidth: true
                }
            }
        }
    }
}
