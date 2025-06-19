
# MSFS IPSet для OpenWRT

Утилита для управления маршрутизацией трафика Microsoft Flight Simulator через VPN

## Установка

### Автоматическая установка (рекомендуется)
Выполните на роутере одну команду:

```bash
wget -qO- https://raw.githubusercontent.com/Nafancheg/msfs-ipset/main/install.sh | sh
```
После установки проверьте работу:

```bash
ipset list vpn_domains | head -n 5
cat /tmp/ipset_debug.log
```

### Ручная установка
Установите зависимости:

```bash
opkg update
opkg install ipset iptables-mod-ipset
```

Склонируйте репозиторий:
```bash
git clone https://github.com/Nafancheg/msfs-ipset.git /tmp/msfs-ipset
cd /tmp/msfs-ipset
```

Скопируйте файлы:
```bash
cp etc/msfs_domains.list /etc/
cp usr/bin/update_msfs_ipset.sh /usr/bin/
cp etc/init.d/msfs-ipset /etc/init.d/
chmod +x /usr/bin/update_msfs_ipset.sh
chmod +x /etc/init.d/msfs-ipset
```

Запустите сервис:
```bash
/etc/init.d/msfs-ipset enable
/etc/init.d/msfs-ipset start
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
