// SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQml
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts

import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.kirigami as Kirigami

import org.kde.tokodon


FormCard.FormCardPage {
    FormCard.FormHeader {
        title: i18nc("@title:group", "General")
    }

    FormCard.FormCard {
        FormCard.FormComboBoxDelegate {
            Layout.fillWidth: true
            id: colorTheme
            text: i18n("Color theme")
            textRole: "display"
            valueRole: "display"
            model: ColorSchemer.model
            Component.onCompleted: currentIndex = ColorSchemer.indexForScheme(Config.colorScheme);
            onCurrentValueChanged: {
                ColorSchemer.apply(currentIndex);
                Config.colorScheme = ColorSchemer.nameForIndex(currentIndex);
                Config.save();
            }
        }




        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            id: continueDelegate
            text: i18n("Continue reading where you last left off")
            description: i18n("If checked, the Home timeline will begin where you last read. The position in the timeline is shared with other clients.")
            checked: Config.continueReading
            enabled: !Config.continueReadingImmutable
            onToggled: {
                Config.continueReading = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            id: autoUpdateDelegate
            text: i18n("Auto-update timelines")
            description: i18n("If checked, Tokodon will automatically update certain timelines as new posts come in.")
            checked: Config.autoUpdate
            enabled: !Config.autoUpdateImmutable
            onToggled: {
                Config.autoUpdate = checked
                Config.save()
            }
        }
        FormCard.FormDelegateSeparator {}

        FormCard.FormSpinBoxDelegate {
            id: autoRefreshDelegate
            label: i18n("Auto-refresh interval (seconds)")
            description: i18n("Periodically refresh the timeline and notifications. Set to 0 to disable.")
            value: Config.autoRefreshInterval
            from: 0
            to: 300
            onValueChanged: {
                Config.autoRefreshInterval = value
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {
            visible: Config.autoRefreshInterval > 0
        }

        FormCard.FormSwitchDelegate {
            id: autoScrollDelegate
            text: i18n("Scroll to top on refresh")
            description: i18n("If checked, the timeline will automatically scroll to the newest posts when it refreshes. Otherwise, a notification banner will appear.")
            checked: Config.autoScrollOnRefresh
            visible: Config.autoRefreshInterval > 0
            onToggled: {
                Config.autoScrollOnRefresh = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            id: askBeforeBoostingDelegate
            text: i18nc("@option:check Boosting means to repost, or retweet", "Ask before boosting")
            checked: Config.askBeforeBoosting
            enabled: !Config.askBeforeBoostingImmutable
            onToggled: {
                Config.askBeforeBoosting = checked
                Config.save()
            }
        }
    }

    FormCard.FormHeader {
        title: i18nc("@title:group", "Sidebar")
    }

    FormCard.FormCard {
        FormCard.FormSwitchDelegate {
            text: i18n("Show Explore")
            checked: Config.showExplore
            onToggled: {
                Config.showExplore = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18n("Show Local")
            checked: Config.showLocal
            onToggled: {
                Config.showLocal = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18n("Show Global")
            checked: Config.showGlobal
            onToggled: {
                Config.showGlobal = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18n("Show Conversations")
            checked: Config.showConversations
            onToggled: {
                Config.showConversations = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18n("Show Favorites")
            checked: Config.showFavorites
            onToggled: {
                Config.showFavorites = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18n("Show Bookmarks")
            checked: Config.showBookmarks
            onToggled: {
                Config.showBookmarks = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18n("Show Following")
            checked: Config.showFollowing
            onToggled: {
                Config.showFollowing = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormSwitchDelegate {
            text: i18n("Show Lists")
            checked: Config.showLists
            onToggled: {
                Config.showLists = checked
                Config.save()
            }
        }
    }

    FormCard.FormHeader {
        title: i18nc("@title:group", "Posts")
    }

    FormCard.FormCard {
        FormCard.FormSwitchDelegate {
            id: showStats
            text: i18n("Show number of favorites and boosts")
            checked: Config.showPostStats
            enabled: !Config.isShowPostStatsImmutable
            onToggled: {
                Config.showPostStats = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {
            below: showStats; above: showLinkPreview
        }

        FormCard.FormSwitchDelegate {
            id: showLinkPreview
            text: i18n("Show link previews")
            checked: Config.showLinkPreview
            enabled: !Config.isShowLinkPreviewImmutable
            onToggled: {
                Config.showLinkPreview = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {
            below: showLinkPreview; above: fontSelector
        }

        FormCard.FormButtonDelegate {
            id: fontSelector
            text: i18n("Content font")
            description: Config.defaultFont.family + " " + Config.defaultFont.pointSize + "pt"
            onClicked: fontDialog.open()

            FontDialog {
                id: fontDialog
                title: i18n("Please choose a font")
                selectedFont: Config.defaultFont
                onAccepted: {
                    Config.defaultFont = selectedFont;
                    Config.save();
                }
            }
        }
    }

    FormCard.FormHeader {
        title: i18nc("@title:group", "Media")
    }

    FormCard.FormCard {
        FormCard.FormSwitchDelegate {
            id: cropMedia
            text: i18n("Crop images on the timeline")
            description: i18n("If unchecked, posts with only one image attached will be uncropped and shown in full.")
            checked: Config.cropMedia
            onToggled: {
                Config.cropMedia = checked
                Config.save()
            }
        }

        FormCard.FormDelegateSeparator {
            below: cropMedia; above: autoPlayGif
        }

        FormCard.FormSwitchDelegate {
            id: autoPlayGif
            text: i18n("Auto-play animated GIFs")
            checked: Config.autoPlayGif
            onToggled: {
                Config.autoPlayGif = checked
                Config.save()
            }
        }
    }
}
