##[ TINYCORE-INSTALL ]#########################################################
#
# This script installs the tinycore linux from a bootable ISO.
#
# 1) Download the Core ISO from http://tinycorelinux.net/downloads.html (11 MB)
#
# 2) Create a virtual machine and boot the ISO. (press [Return] when asked)
#
# 3) Download this script:
#
#         tcd-load -w -o openssl.tcz                  <- enable ssl (for https)
#         wget http://bit.ly/tinycore-install         <- download script*
#         chmod +x tinycore-install                   <- make it executable
#         ./tinycore-install                          <- run
#
# 3) What tinycore-install does:
#    - Create and format a single partition using whole disk space
#    - Install Kernel
#    - Install GRUB
#    - Setup GRUB to boot from disk
# 
# By paulo.amaral(a)gmail(dot)com - https://github.com/paulera
# Based on @smileymattj video: http://www.youtube.com/watch?v=0QMY3V5XLj8
#
# Download: wget http://bit.ly/tinycore-install
#           (requires openssl - rtfm)
#

#!/bin/sh

function step() {
	echo -e "\e[32m$*\e[0m";
}

echo "This will setup your partitions, install kernel and grub, and any"
echo "existing data will be lost. Just make sure you run this in a clean"
echo "environment, from the bootable ISO, and you should be fine."
echo
read -p "Continue (y/n)? " -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	step("\n\n\n###### Create partition ######\n\n")
	set -x
	echo -e "n\np\n1\n\n\n\n\na\n1\nw" | fdisk /dev/sda
	set +x

	step("\n\n\n###### Format partition ######\n\n")
	set -x
	sudo mkfs.ext4 /dev/sda1
	set +x

	step("\n\n\n###### Update /etc/fstab ######\n\n")
	set -x
	sudo rebuildfstab
	set +x

	step("\n\n\n###### Mount disk and cd ######\n\n")
	set -x
	sudo mount /mnt/sda1
	sudo mount /mnt/sr0
	set +x

	step("\n\n\n###### Create directories ######\n\n")
	set -x
	sudo mkdir -p /mnt/sda1/boot/grub
	sudo mkdir -p /mnt/sda1/tce/optional
	set +x

	step("\n\n\n###### Copy kernel ######\n\n")
	set -x
	sudo cp -p /mnt/sr0/boot/core.gz /mnt/sda1/boot/
	sudo cp -p /mnt/sr0/boot/vmlinuz /mnt/sda1/boot/
	set +x

	step("\n\n\n###### Install grub ######\n\n")
	set -x
	tce-load -w -i grub-0.97-splash.tcz
	sudo cp -p /usr/lib/grub/i386-pc/* /mnt/sda1/boot/grub/
	touch /mnt/sda1/tce/mydata.tgz
	set +x

	step("\n\n\n###### Create menu for grub ######\n\n")
	set -x
	sudo sh -c 'echo -e "default 0\ntimeout 0\ntitle MicroCore\nkernel /boot/vmlinuz quiet\ninitrd /boot/core.gz" > mnt/sda1/boot/grub/menu.lst'
	set +x

	step("\n\n\n###### Create master boot record in partition ######\n\n")
	set -x
	sudo sh -c 'echo -e "root (hd0,0)\nsetup (hd0)\nquit" | grub --batch'
	set +x

	step("\n\n\n###### Done! ######\n\n")
	echo "Script finished. Remove ISO from drive and reboot."

fi
