# Tokodon (Custom Fork)

<img width="1076" height="1353" alt="Tokodon" src="https://github.com/user-attachments/assets/9b140b68-cb17-4c23-87c0-bcb6b338d717" />

<img width="930" height="1239" alt="Tokodon_Compose_Autocomplete" src="https://github.com/user-attachments/assets/043261a6-2d79-496a-afbd-966f194c73c4" />

<img width="641" height="256" alt="Tokodon_Repost" src="https://github.com/user-attachments/assets/c7489e7d-3f46-4530-a46c-8da4b9844fb6" />

<img width="1030" height="1032" alt="Tokodon_Settings" src="https://github.com/user-attachments/assets/4998a6b7-d68a-48fb-a90e-0956f04b4835" />



This is a custom fork of Tokodon that includes several improvements, bug fixes, and additional features over the upstream project.

## Improvements & Fixes

* **Android/SailfishOS code cleanup**
* **Icon change**
* **Re-toot and Quote**
* **Silent auto-refresh** — no visual flash, with a "New posts available" banner.
* **Notifications polling** — badge updated every 30s.
* **Customizable sidebar** — 8 toggles in Settings (Explore, Local, Global hidden by default).
* **Card-style posts** — rounded borders, margins, no separator line.
* **Auto-mark-as-read** — notifications are marked as read when viewed.
* **Bug fixes** — Load More, missing pageId, padeId typo, binding loop.
* **PKGBUILD** — to install as an Arch Linux package.
* **Mention autocomplete when typing @**: When you type in the composer and enter the at sign with 2 more characters (e.g., `@al`), Tokodon makes two searches in the background. A popup menu will appear near the cursor showing first the results of accounts you follow, and right below it, the rest of the global accounts in the Fediverse. Clicking on one will autocomplete the name and leave a space ready for you to keep typing.
* **Bookmark icon improvement**: Changed the bookmarks icon in posts to `bookmark-new`. It now looks much more modern, simple, and acts like an individual "Add to bookmarks" marker, removing its previous confusing appearance.

---

A modern client for [Mastodon](https://joinmastodon.org/) and other
decentralized servers that implement its API (such as Pixelfed).

## Features

* Real-time notifications, including background push notifications (using [KUnifiedPush](https://invent.kde.org/libraries/kunifiedpush).)
* Direct messages.
* Editing & deleting toots.
* Multiple accounts and cross-account actions.
* Searching for users, hashtags and posts.
* Moderation tools like viewing a server's accounts, email blocks and more. 

## Supported Services

Tokodon supports services that implement the [Mastodon Client API](https://docs.joinmastodon.org/api/). This includes most popular Fediverse software, such as:

* [Mastodon](https://joinmastodon.org) (and its forks)
* [Akkoma](https://akkoma.social/) and [Pleroma](https://pleroma.social/)
* [GoToSocial](https://gotosocial.org/)
* [FireFish](https://codeberg.org/firefish/firefish), [Iceshrimp.NET](https://iceshrimp.net) and other Misskey forks

Other services may work in Tokodon, although keep in mind it's not possible to support every extra feature. We also tend
to test against the latest Mastodon, so your experience may depend on your Fediverse software. 

## Get It

Details on where to find stable releases of Tokodon can be found on its
[homepage](https://apps.kde.org/tokodon). An Android version can be found
in the [KDE Nightly F-Droid repository](https://community.kde.org/Android/F-Droid).

## Building

The easiest way to make changes and test Tokodon during development is to [build it with kde-builder](https://develop.kde.org/docs/getting-started/building/kde-builder-compile/).

## Contributing

Please refer to the [contributing document](/CONTRIBUTING.md) for everything you need to know to get started contributing to Tokodon.

## License

![GPLv3](https://www.gnu.org/graphics/gplv3-127x51.png)

This project is licensed under the GNU General Public License 3. The logo was done by Bugsbane and licensed under
CC-BY-4.0.
