#!/bin/sh

set -e

echo "Проверка необходимых инструментов..."
command -v wget >/dev/null || { echo "Ошибка: wget не установлен!"; exit 1; }
ping -c1 github.com >/dev/null || { echo "Ошибка: нет подключения к интернету!"; exit 1; }

echo "Устанавливаем зависимости..."
opkg update >/dev/null
opkg install ipset kmod-ipt-ipset >/dev/null

echo "Скачиваем файлы конфигурации..."
mkdir -p /tmp/msfs-install
wget -qO- https://github.com/Nafancheg/msfs-ipset/archive/main.tar.gz | \
  tar -xz -C /tmp/msfs-install --strip-components=1 || {
    echo "Ошибка при загрузке или распаковке архива!"; exit 1;
}

echo "Копируем файлы..."
cp -f /tmp/msfs-install/etc/msfs_domains.list /etc/
cp -f /tmp/msfs-install/usr/bin/update_msfs_ipset.sh /usr/bin/
cp -f /tmp/msfs-install/etc/init.d/msfs-ipset /etc/init.d/

if [ -f /tmp/msfs-install/usr/lib/lua/luci/controller/msfs.lua ]; then
    echo "Устанавливаем LUCI интерфейс..."
    mkdir -p /usr/lib/lua/luci/controller
    mkdir -p /usr/lib/lua/luci/model/cbi
    cp -r /tmp/msfs-install/usr/lib/lua/luci/* /usr/lib/lua/luci/
fi

echo "Настраиваем права..."
chmod +x /usr/bin/update_msfs_ipset.sh
chmod +x /etc/init.d/msfs-ipset

echo "Запускаем сервис..."
/etc/init.d/msfs-ipset enable
/etc/init.d/msfs-ipset start

if [ -f /usr/lib/lua/luci/controller/msfs.lua ]; then
    echo "Перезагружаем LUCI..."
    rm -rf /tmp/luci-modulecache
    /etc/init.d/uhttpd restart >/dev/null
fi

rm -rf /tmp/msfs-install

# Настройка cron задач
echo "Настраиваем cron-задачи..."

# Получить текущий crontab, добавить задачи, если их нет
(crontab -l 2>/dev/null | grep -v -F "/usr/bin/update_msfs_ipset.sh" ; echo "0 */2 * * * /usr/bin/update_msfs_ipset.sh") | crontab -
(crontab -l 2>/dev/null | grep -v -F "echo '' > /tmp/ipset_debug.log" ; echo "0 3 * * * echo '' > /tmp/ipset_debug.log") | crontab -


echo "✅ Установка завершена!"
echo "Откройте LuCI: Сервисы → MSFS Routing"
