#!/bin/sh
IPSET="vpn_domains"
TEMP_SET="vpn_temp"
DOMAINS_FILE="/etc/msfs_domains.list"
DNS_SERVER="1.1.1.1"
LOG="/tmp/ipset_debug.log"

echo "=== Обновление начато: $(date) ===" > $LOG

# Создаем временный набор (если не существует)
ipset create $TEMP_SET hash:ip maxelem 1024 2>/dev/null || ipset flush $TEMP_SET

# Обработка доменов
grep -v '^$\|^#' $DOMAINS_FILE | while read domain; do
    echo "🔍 $domain" >> $LOG
    dig +short $domain @$DNS_SERVER | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' | while read ip; do
        if ipset add $TEMP_SET $ip 2>>$LOG; then
            echo "✅ $ip" >> $LOG
        else
            echo "ℹ️ $ip (дубликат)" >> $LOG
        fi
    done
done

# Создаем основной набор, если не существует
ipset create $IPSET hash:ip maxelem 1024 2>/dev/null

# Атомарная замена наборов
ipset swap $TEMP_SET $IPSET && ipset destroy $TEMP_SET || {
    echo "⚠️ Ошибка замены наборов, копируем вручную" >> $LOG
    ipset flush $IPSET
    ipset list $TEMP_SET | grep -E '^[0-9]' | while read ip; do
        ipset add $IPSET $ip
    done
    ipset destroy $TEMP_SET
}

echo "=== Итог ===" >> $LOG
ipset list $IPSET | grep -E 'Number of entries|Members' >> $LOG
echo "Обновлено: $(ipset list $IPSET | grep 'Number of entries' | awk '{print $4}') IP-адресов"
