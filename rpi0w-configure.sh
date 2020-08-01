#!/bin/zsh 
# GistID: d11625d87ef73092987f4919defe11cf

dev=$1
SSID="$2"
PASS="$3"

function umountboot {
    umount ${dev}1 || true
    umount ${dev}2 || true
} 

mount ${dev}2 /mnt/
mkdir -p /mnt/boot
mount ${dev}1 /mnt/boot
trap umountboot EXIT

touch /mnt/etc/systemd/network/08-wlan0.network
cat << EOF > /mnt/etc/systemd/network/08-wlan0.network

[Match]
Name=wlan0

[Network]
DHCP=yes
EOF

touch /mnt/etc/systemd/network/16-usb0.network
cat << EOF > /mnt/etc/systemd/network/16-usb0.network

[Match]
Name=usb0

[Network]
Address=192.168.51.1/24
DHCPServer=yes
DHCP=yes
EOF

wpa_passphrase ${SSID} ${PASS} > /mnt/etc/wpa_supplicant/wpa_supplicant-wlan0.conf

ln -sf \
   /lib/systemd/system/wpa_supplicant@.service \
   /mnt/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service



cp ./otg-mode.sh /mnt/root/otg-mode.sh
chmod +x /mnt/root/otg-mode.sh
##
#curl https://gist.githubusercontent.com/kannab98/1b0b7c6a6ecbe89dbcafd1264ff28572/raw/85167ca2e47a05186bd2c05c926734f892918f93/otg-mode.sh --output kek.txt


touch /mnt/etc/systemd/system/otg.service
cat << EOF > /mnt/etc/systemd/system/otg.service
[Unit]
Description=Pi Zero USB Gadget

[Service]
ExecStart=/root/otg-mode.sh

[Install]
WantedBy=multi-user.target
EOF

touch /mnt/etc/sysctl.d/10-sysctl.conf
cat << EOF > /mnt/etc/sysctl.d/10-sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.ip_default_ttl=65
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
EOF

touch /mnt/etc/ssh/sshd_config
cat << EOF  > /mnt/etc/ssh/sshd_config
PubkeyAuthentication        yes
AuthorizedKeysFile	        .ssh/authorized_keys
PasswordAuthentication      no
PermitRootLogin             yes
EOF

# for raspbian
ln -sf \
   /mnt/lib/systemd/system/ssh.service \
   /mnt/etc/systemd/system/multi-user.target.wants/ssh.service

ln -sf \
   /mnt/lib/systemd/system/ssh.service \
   /mnt/etc/systemd/system/sshd.service

## copy my public key to authorized keys in guest device (\mnt)
mkdir -p /mnt/root/.ssh

cp $HOME/.ssh/id_rsa.pub /mnt/root/.ssh/authorized_keys

ln -sf \
   /mnt/etc/systemd/system/otg.service \
   /mnt/etc/systemd/system/multi-user.target.wants/otg.service


