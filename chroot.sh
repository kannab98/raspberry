pacman-key --init
pacman-key --populate
pacman -Syu sudo 

echo 'dtoverlay=dwc2,dr_mode=otg' >> /boot/config.txt

useradd -G wheel -m kannab
echo 'kannab:1234' | chpasswd 
echo "kannab  ALL=(ALL) ALL" >> /etc/sudoers


