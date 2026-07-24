# Maintainer: elav
# Custom PKGBUILD for Tokodon (modified version) built from local source

pkgname=tokodon-custom
pkgver=26.08.13
pkgrel=1
pkgdesc='Mastodon client for Plasma (custom build with auto-refresh, sidebar customization, and notification badges)'
arch=(x86_64)
url='https://apps.kde.org/tokodon/'
license=(GPL-3.0-only)
depends=(
    # Qt 6
    qt6-base
    qt6-declarative
    qt6-multimedia
    qt6-svg
    qt6-websockets
    qt6-webview
    qt6-5compat

    # KDE Frameworks 6
    kconfig
    kcoreaddons
    kcolorscheme
    kdbusaddons
    ki18n
    kio
    kirigami
    kirigami-addons
    knotifications
    kwindowsystem
    purpose
    qqc2-desktop-style
    sonnet

    # Other
    qtkeychain-qt6
    qcoro
    kitemmodels
    prison
)
makedepends=(
    cmake
    extra-cmake-modules
    git
    python
)
optdepends=(
    'kunifiedpush: Push notification support'
    'openssl: Push notification key generation'
)
provides=(tokodon)
conflicts=(tokodon)

# Build from local source directory
# Copy the source tree to $srcdir during prepare()
_srcdir="/home/elav/Developer/Tokodon"

prepare() {
    ln -sfn "$_srcdir" "$srcdir/tokodon"
}

build() {
    cmake -B build -S tokodon \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DBUILD_TESTING=OFF
    cmake --build build -j 4
}

package() {
    DESTDIR="$pkgdir" cmake --install build
}
