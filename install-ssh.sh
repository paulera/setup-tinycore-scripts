####################################
# This script is far from finished #
####################################

# install open SSH
sudo tce-load -w -i openssh.tcz

# Backup original config files
sudo cp /usr/local/etc/ssh/sshd_config /usr/local/etc/ssh/sshd_config.original
sudo cp /usr/local/etc/ssh/ssh_config /usr/local/etc/ssh/ssh_config.original

# command to startup - add in /opt/boot
# sudo /usr/local/etc/init.d/openssh start

# might need this as well:
# ifconfig eth0 up
