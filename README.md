Установка

wget -qO- https://raw.githubusercontent.com/Nafancheg/msfs-ipset/main/install.sh | sh

После установки проверьте работу в ssh:

ipset list vpn_domains | head -n 5
cat /var/log/msfs_ipset.log
