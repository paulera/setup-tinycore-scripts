

###############################################################################
# This script is a very initial setup for a micro core linux installation.
# 1) Download the Core ISO from http://tinycorelinux.net/downloads.html .
# 2) Create a virtual machine and boot the ISO.
# 3) Run this script. It will:
#    - Create and format a single partition using whole disk space
#    - Install Kernel
#    - Install GRUB
#    - Setup GRUB to boot from disk
# 
# Credits:
# Author: paulo.amaral(a)gmail(dot)com - https://github.com/paulera
# Based on @smileymattj video: http://www.youtube.com/watch?v=0QMY3V5XLj8


#!/bin/sh


echo "This will setup your partitions, install kernel and grub, and any existing"
echo "data will be lost. Just make sure you run this first, from the bootable ISO,"
echo "and you should be fine."
echo
read -p "Continue (y/n)? " -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo -e "\n\n\n###### Create partition ######\n\n" 
	echo -e "n\np\n1\n\n\n\n\na\n1\nw" | fdisk /dev/sda

	echo -e "\n###### Format partition ######\n\n" 
	sudo mkfs.ext4 /dev/sda1

	echo -e "\n###### Update /etc/fstab ######\n\n" 
	sudo rebuildfstab

	echo -e "\n###### Mount disk and cd ######\n\n" 
	sudo mount /mnt/sda1
	sudo mount /mnt/sr0

	echo -e "\n###### Create directories ######\n\n" 
	sudo mkdir -p /mnt/sda1/boot/grub
	sudo mkdir -p /mnt/sda1/tce/optional

	echo -e "\n###### Copy kernel ######\n\n" 
	sudo cp -p /mnt/sr0/boot/core.gz /mnt/sda1/boot/
	sudo cp -p /mnt/sr0/boot/vmlinuz /mnt/sda1/boot/

	echo -e "\n###### Install grub ######\n\n" 
	tce-load -w -i grub-0.97-splash.tcz
	sudo cp -p /usr/lib/grub/i386-pc/* /mnt/sda1/boot/grub/
	touch /mnt/sda1/tce/mydata.tgz

	echo -e "\n###### Create menu for grub ######\n\n" 
	sudo sh -c 'echo -e "default 0\ntimeout 0\ntitle MicroCore\nkernel /boot/vmlinuz quiet\ninitrd /boot/core.gz" > mnt/sda1/boot/grub/menu.lst'

	echo -e "\n###### Create master boot record in partition ######\n\n" 
	sudo sh -c 'echo -e "root (hd0,0)\nsetup (hd0)\nquit" | grub --batch'

	echo -e "\n###### Done! ######\n\n" 
	echo "Job done. Remove disk from drive and reboot."
fi
