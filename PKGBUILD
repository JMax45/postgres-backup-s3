pkgname=postgres-backup-s3
pkgver=1.0.0
pkgrel=1
pkgdesc="A bash script for backing up PostgreSQL to S3 periodically"
arch=('any')
url="https://github.com/JMax45/postgres-backup-s3"
license=('MIT')
depends=('postgresql-libs' 'aws-cli')

# Local build
build() {
    mkdir "postgres-backup-s3-$pkgver"
    cp "../postgres-backup-s3.sh" "postgres-backup-s3-$pkgver/postgres-backup-s3.sh"
    cp "../postgres-backup-s3.service" "postgres-backup-s3-$pkgver/postgres-backup-s3.service"
    cp "../postgres-backup-s3.timer" "postgres-backup-s3-$pkgver/postgres-backup-s3.timer"
    cp "../postgres-backup-s3.conf" "postgres-backup-s3-$pkgver/postgres-backup-s3.conf"
    tar -czvf "$pkgver.tar.gz" "postgres-backup-s3-$pkgver"
}


# Production build
#source=('$url/archive/refs/tags/v$pkgver.tar.gz')
#sha256sums=('55a0be7f0549f358f57dbb70b2b7ec70ef0a3a0cc9f05431fe8b67ed4b6d4134')

package() {
  cd "$srcdir/postgres-backup-s3-$pkgver"
  
  # Copy files to the appropriate locations
  install -Dm755 postgres-backup-s3.sh "$pkgdir/usr/bin/postgres-backup-s3"
  install -Dm644 postgres-backup-s3.service "$pkgdir/usr/lib/systemd/system/postgres-backup-s3.service"
  install -Dm644 postgres-backup-s3.timer "$pkgdir/usr/lib/systemd/system/postgres-backup-s3.timer"
  
  # Install the configuration file to /etc
  install -Dm644 postgres-backup-s3.conf "$pkgdir/etc/postgres-backup-s3.conf"
}
