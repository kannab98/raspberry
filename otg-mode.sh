#!/bin/sh
# GistID: 1b0b7c6a6ecbe89dbcafd1264ff28572
modprobe libcomposite 
# Create a gadget called usb-gadgets
cd /sys/kernel/config/usb_gadget/
mkdir -p usb-gadgets
cd usb-gadgets

# Configure the gadget
# ==========================

# Configure our gadget details
echo 0x1d6b > idVendor # Linux Foundation
#echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0137 > idProduct 

#echo 0x04b3 > idVendor
#echo 0x4010 > idProduct
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2
mkdir -p strings/0x409

echo "02938ursjlkdng1092" > strings/0x409/serialnumber
echo "Pi Zero USB Gadget" > strings/0x409/manufacturer
echo "Pi Zero USB Gadget" > strings/0x409/product

mkdir -p configs/c.1/strings/0x409

# This describes the only configuration, free text
echo "Config 1: Test gadget" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower
echo 0x80 > configs/c.1/bmAttributes
# =====================================
# Create gadget functions

# Ethernet gadget
# -------------------------

F_NAME=usb0     # Freely selectable name
F_TYPE=rndis  #RNDIS gadget
mkdir -p functions/$F_TYPE.$F_NAME
HOST="32:70:05:18:ff:7a" # "HostPC"
SELF="32:70:05:18:ff:7b" # "Ethernet Gadget"
echo $HOST > functions/$F_TYPE.$F_NAME/host_addr
echo $SELF > functions/$F_TYPE.$F_NAME/dev_addr
ln -s functions/$F_TYPE.$F_NAME configs/c.1/


#USB=mass_storage
#mkdir -p functions/$USB.$F_NAME
#pwd > /home/kannab/tmp.txt
#echo 1 > functions/$USB.$F_NAME/stall
#echo 1 > functions/$USB.$F_NAME/lun.0/removable
#echo 0 > functions/$USB.$F_NAME/lun.0/ro
#echo /home/kannab/file.bin > functions/$USB.$F_NAME/lun.0/file
#ln -s functions/$USB.$F_NAME configs/c.1/

mkdir -p functions/hid.usb0
echo 1 > functions/hid.usb0/protocol
echo 1 > functions/hid.usb0/subclass
echo 8 > functions/hid.usb0/report_length
echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.usb0/report_desc
ln -s functions/hid.usb0 configs/c.1/
# End ethernet gadget
# ------------------------

# End functions
# ========================

# Enable gadgets
ls /sys/class/udc > UDC

iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i usb0 -o wlan0 -j ACCEPT

