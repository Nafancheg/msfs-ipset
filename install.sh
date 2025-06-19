#!/bin/sh

# Установка зависимостей
opkg update
opkg install ipset iptables-mod-ipset

# Копирование файлов
cp -r etc/* /etc/
cp -r usr/* /usr/

# Права доступа
chmod +x /usr/bin/update_msfs_ipset.sh
chmod +x /etc/init.d/msfs-ipset

# Включение сервиса
/etc/init.d/msfs-ipset enable
/etc/init.d/msfs-ipset start

# Перезагрузка LUCI
rm -rf /tmp/luci-modulecache
/etc/init.d/uhttpd restart

echo "Установка завершена. Интерфейс: Сервисы -> MSFS Routing"
