#!/bin/zsh 
#GistID: 1b0b7c6a6ecbe89dbcafd1264ff28572

for arg in "$@"; do
    case $arg in 
        -s=* | --system=*)
            os="${arg#*=}"
            if [ "$OS" = "raspbian" ]; then
                urL=https://downloads.raspberrypi.org/raspios_lite_armhf_latest
                extract=bsdtar
                file=./ArchLinuxARM-rpi-latest.tar.gz

            else
                url=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
                extract=unzip
                file=./RaspberryPiOS-lite.zip

            fi


            shift
            ;;
        -p=* | --path=*)
            imgdir="${arg#*=}"
            shift
            ;;
        -d=* | --disk=*)
            dev="${arg#*=}"
            ;;
    esac
done



function umountboot {
    umount boot || true
    umount root || true
}

function install(){

    if [ "$os" = "raspbian" ]; then
        dd if=$file of=$dev status=progress
    else
        cd $(mktemp -d)
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
        bsdtar -xpf $file -C root
        mv root/boot/* boot
    fi
    
}
##dev=$1




## RPi1/Zero (armv6h):

$file=pwd$file
#install $os





#SSID="$2"
#PASS="$3"

#cat << EOF >> root/etc/systemd/network/25-wireless.network
#[Match]
#Name=wlan0

#[Network]
#DHCP=yes
#EOF

#wpa_passphrase ${SSID} ${PASS} > root/etc/wpa_supplicant/wpa_supplicant-wlan0.conf

#ln -s \
   #/usr/lib/systemd/system/wpa_supplicant@.service \
   #root/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service

#sync

#mv root/boot/* boot

#cp /home/kannab/raspberry/install/settings.sh root/home/alarm/
#chmod +x root/home/alarm/settings.sh

#cat << EOF >> root/etc/systemd/system/badusb.service
#[Unit]
#Description=Pi Zero USB Gadget

#[Service]
#ExecStart=/home/alarm/settings.sh

#[Install]
#WantedBy=multi-user.target
#EOF


#cat << EOF  > root/etc/ssh/sshd_config
#PubkeyAuthentication yes
#AuthorizedKeysFile	.ssh/authorized_keys
#PasswordAuthentication no
#EOF

## copy my public key to authorized keys in guest device (\mnt)
#mkdir -p root/home/alarm/.ssh

#cp /home/kannab/.ssh/id_rsa.pub root/home/alarm/.ssh/authorized_keys

#ln -sf \
   #root/etc/systemd/system/badusb.service \
   #root/etc/systemd/system/multi-user.target.wants/badusb.service


# vim:filetype=sh
