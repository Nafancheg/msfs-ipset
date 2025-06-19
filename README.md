
# MSFS IPSet для OpenWRT

Утилита для управления маршрутизацией трафика Microsoft Flight Simulator через VPN c обходом блокировок от itdoginfo - domain-routing-openwrt

## Установка

### Автоматическая установка (рекомендуется)
Выполните на роутере одну команду:

```bash
wget -qO- https://raw.githubusercontent.com/Nafancheg/msfs-ipset/main/install.sh | sh
```
После установки проверьте работу:

```bash
ipset list vpn_domains | head -n 5
```

Пример вывода
```bash
root@OpenWrt: ipset list vpn_domains | head -n 5
Name: vpn_domains
Type: hash:ip
Revision: 6
Header: family inet hashsize 1024 maxelem 1024 bucketsize 12 initval 0x9c301da8
Size in memory: 696
```
И лог файл:

```bash
cat /tmp/ipset_debug.log
```
Пример вывода
```bash
🔍 mapsplatform.bing.com
ipset v7.21: Element cannot be added to the set: it's already added
ℹ️ 150.171.27.10 (дубликат)
ipset v7.21: Element cannot be added to the set: it's already added
ℹ️ 150.171.28.10 (дубликат)
🔍 tiles.virtualearth.net
✅ 74.178.114.10
🔍 dev.virtualearth.net
ipset v7.21: Element cannot be added to the set: it's already added
ℹ️ 13.107.246.45 (дубликат)
🔍 imagery.bing.com
ipset v7.21: Element cannot be added to the set: it's already added
ℹ️ 150.171.27.10 (дубликат)
ipset v7.21: Element cannot be added to the set: it's already added
ℹ️ 150.171.28.10 (дубликат)
🔍 msfs-api.azurewebsites.net
🔍 msfs-marketplace.azureedge.net
🔍 msfs-usercontent.azureedge.net
🔍 msfs-userdata.azureedge.net
🔍 msfs-weatherdata.azureedge.net
🔍 marketplace.flightsimulator.com
=== Итог ===
Number of entries: 12
```

### Ручное управление

Обновить IP-адреса:
```bash
/usr/bin/update_msfs_ipset.sh
```

Просмотр списка доменов:
```bash
cat /etc/msfs_domains.list
```

Проверка работы:
```bash
ipset list vpn_domains | head -n 10
```

### Обновление
Для обновления выполните:
```bash
wget -qO- https://raw.githubusercontent.com/Nafancheg/msfs-ipset/main/install.sh | sh
```

Или вручную:
```bash
cd /tmp/msfs-ipset
git pull origin main
cp -f etc/msfs_domains.list /etc/
/etc/init.d/msfs-ipset restart
```

### Настройка

Основные файлы конфигурации:

/etc/msfs_domains.list - список доменов для маршрутизации

/etc/init.d/msfs-ipset - параметры запуска сервиса

### Для добавления новых доменов:

Отредактируйте файл /etc/msfs_domains.list

Выполните:

```bash
/usr/bin/update_msfs_ipset.sh
```

### Логирование

Логи работы сохраняются в:
```bash
/var/log/msfs_ipset.log
```

### Удаление
```bash
/etc/init.d/msfs-ipset stop
/etc/init.d/msfs-ipset disable
rm /etc/init.d/msfs-ipset
rm /usr/bin/update_msfs_ipset.sh
rm /etc/msfs_domains.list
```

### Совместимость
Проверено на:
OpenWRT 21.02+

@DmitryAfanasev 2025
