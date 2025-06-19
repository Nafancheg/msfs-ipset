# MSFS IPSet для OpenWRT

Утилита для управления маршрутизацией трафика Microsoft Flight Simulator через VPN.  
Создаёт `ipset`-список из доменов, указанных в `/etc/msfs_domains.list`, и позволяет пометить соответствующий трафик для маршрутизации через VPN или приоритезации.

---

## 📦 Установка

### ✅ Автоматическая установка (рекомендуется)

Выполните на роутере одну команду:

```sh
wget -qO- https://raw.githubusercontent.com/Nafancheg/msfs-ipset/main/install.sh | sh
