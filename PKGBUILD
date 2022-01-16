# Maintainer: Toni Tauro <eye@eyenx.ch>
# Co-Maintainer: Lukas Grossar <lukasgrossar@gmail.com>

pkgname=k0sctl-bin
pkgver=0.12.2
pkgrel=1
pkgdesc="A bootstrapping and management tool for k0s clusters."
arch=('x86_64')
url="https://github.com/k0sproject/k0sctl"
license=('Apache')
source=("k0sctl-linux-x64-$pkgver::https://github.com/k0sproject/k0sctl/releases/download/v${pkgver}/k0sctl-linux-x64")
sha256sums=('d1fa534a96d194f31b8ba5e8f1224f5796faa4b1946fdb790c5d54e165c0503b')
options=(!strip)

package() {
  install -Dm 755 "$srcdir/k0sctl-linux-x64-$pkgver" "$pkgdir/usr/bin/k0sctl"
}
