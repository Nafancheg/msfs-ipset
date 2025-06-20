#!/bin/sh

set -e

echo "Проверка необходимых инструментов..."
command -v wget >/dev/null || { echo "Ошибка: wget не установлен!"; exit 1; }
ping -c1 github.com >/dev/null || { echo "Ошибка: нет подключения к интернету!"; exit 1; }

echo "Устанавливаем зависимости..."
opkg update >/dev/null
opkg install ipset kmod-ipt-ipset bind-dig iptables-mod-ipopt iptables-zz-legacy luci luci-base luci-mod-admin-full luci-compat luci-theme-bootstrap >/dev/null || {
    echo "⚠️ Некоторые пакеты не установились, продолжаем..."
}

echo "Скачиваем и распаковываем файлы..."
mkdir -p /tmp/msfs-install
wget -qO /tmp/msfs.tar.gz https://github.com/Nafancheg/msfs-ipset/archive/main.tar.gz
tar -xzf /tmp/msfs.tar.gz -C /tmp/msfs-install
mv /tmp/msfs-install/msfs-ipset-main/* /tmp/msfs-install/
rm -rf /tmp/msfs-install/msfs-ipset-main

echo "Копируем файлы..."
[ -f /tmp/msfs-install/etc/msfs_domains.list ] && cp -f /tmp/msfs-install/etc/msfs_domains.list /etc/
[ -f /tmp/msfs-install/usr/bin/update_msfs_ipset.sh ] && cp -f /tmp/msfs-install/usr/bin/update_msfs_ipset.sh /usr/bin/
[ -f /tmp/msfs-install/etc/init.d/msfs-ipset ] && cp -f /tmp/msfs-install/etc/init.d/msfs-ipset /etc/init.d/

if [ -f /tmp/msfs-install/usr/lib/lua/luci/controller/msfs.lua ]; then
    echo "Устанавливаем LUCI интерфейс..."
    mkdir -p /usr/lib/lua/luci/{controller,model/cbi}
    cp -f /tmp/msfs-install/usr/lib/lua/luci/controller/msfs.lua /usr/lib/lua/luci/controller/
    cp -f /tmp/msfs-install/usr/lib/lua/luci/model/cbi/msfs.lua /usr/lib/lua/luci/model/cbi/
fi

echo "Настраиваем права..."
chmod +x /usr/bin/update_msfs_ipset.sh 2>/dev/null
chmod +x /etc/init.d/msfs-ipset 2>/dev/null

echo "Запускаем сервис..."
[ -x /etc/init.d/msfs-ipset ] && {
    /etc/init.d/msfs-ipset enable
    /etc/init.d/msfs-ipset start
}

if [ -f /usr/lib/lua/luci/controller/msfs.lua ]; then
    echo "Перезагружаем LUCI..."
    rm -rf /tmp/luci-modulecache
    /etc/init.d/uhttpd restart >/dev/null
fi

echo "Настраиваем cron-задачи..."
(crontab -l 2>/dev/null | grep -v "/usr/bin/update_msfs_ipset.sh"; echo "0 */2 * * * /usr/bin/update_msfs_ipset.sh") | crontab -
(crontab -l 2>/dev/null | grep -v "echo '' > /tmp/ipset_debug.log"; echo "0 3 * * * echo '' > /tmp/ipset_debug.log") | crontab -

echo "✅ Установка завершена!"
echo "Откройте LuCI: Сервисы → MSFS Routing"
