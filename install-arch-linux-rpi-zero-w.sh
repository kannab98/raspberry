#!/bin/sh -exu
dev=$1
cd $(mktemp -d)

function umountboot {
    umount boot || true
    umount root || true
}

# RPi1/Zero (armv6h):
archlinux=/tmp/ArchLinuxARM-rpi-latest.tar.gz
url=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz

# RPi2 (armv7h):
# archlinux=/tmp/ArchLinuxARM-rpi-2-latest.tar.gz
# url=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz

curl -L -o $archlinux -z $archlinux $url
parted -s $dev mklabel msdos
parted -s $dev mkpart primary fat32 1 128
parted -s $dev mkpart primary ext4 128 -- -1
mkfs.vfat ${dev}1
mkfs.ext4 -F ${dev}2
mkdir -p boot
mount ${dev}1 boot
trap umountboot EXIT
mkdir -p root
mount ${dev}2 root

bsdtar -xpf $archlinux -C root
sync
mv root/boot/* boot

# Commands to configure WiFi before first boot (netctl-auto)
# - you need to temp edit root/etc/pacman.d to point to /path/to/root/etc/pacman.d/mirrorlist
# - change it back after installing
# pacman  -r root --arch armv6h --config root/etc/pacman.conf --cachedir root/var/cache/pacman/pkg --dbpath root/var/lib/pacman -Sy
# pacman  -r root --arch armv6h --config root/etc/pacman.conf --cachedir root/var/cache/pacman/pkg --dbpath root/var/lib/pacman -S wpa_actiond
# ln -sf /usr/lib/systemd/system/netctl-auto@.service root/etc/systemd/system/netctl-auto@wlan0.service
# cat >root/etc/netctl/wlan0-SSID <<EOF
# Description='WiFi - SSID'
# Interface=wlan0
# Connection=wireless
# Security=none
# ESSID=enter-ssid-here
# IP=dhcp
# EOF
