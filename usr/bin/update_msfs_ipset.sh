#!/bin/sh
IPSET="vpn_domains"
TEMP_SET="vpn_temp"
DOMAINS_FILE="/etc/msfs_domains.list"
DNS_SERVER="1.1.1.1"
LOG="/tmp/ipset_debug.log"

# Проверка наличия файла доменов
if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Ошибка: файл $DOMAINS_FILE не найден!" >&2
    exit 1
fi

# Проверка наличия команд
for cmd in ipset dig; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Ошибка: команда $cmd не найдена!" >&2
        exit 1
    fi
done

echo "=== Обновление начато: $(date) ===" > "$LOG"

# Создаем временный набор (если не существует)
ipset create "$TEMP_SET" hash:ip maxelem 1024 2>/dev/null || ipset flush "$TEMP_SET"

# Обработка доменов
grep -v '^$\|^#' "$DOMAINS_FILE" | while read -r domain; do
    # Пропускаем пустые строки и строки только с пробелами
    [ -n "$(echo "$domain" | tr -d ' \t')" ] || continue
    
    echo "🔍 $domain" >> "$LOG"
    # Добавляем таймаут для dig и обработку ошибок
    if dig_result=$(dig +short +time=5 +tries=2 "$domain" @"$DNS_SERVER" 2>>"$LOG"); then
        echo "$dig_result" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' | while read -r ip; do
            if ipset add "$TEMP_SET" "$ip" 2>>"$LOG"; then
                echo "✅ $ip" >> "$LOG"
            else
                echo "ℹ️ $ip (дубликат)" >> "$LOG"
            fi
        done
    else
        echo "❌ Ошибка DNS запроса для $domain" >> "$LOG"
    fi
done

# Создаем основной набор, если не существует
ipset create "$IPSET" hash:ip maxelem 1024 2>/dev/null

# Атомарная замена наборов
if ipset swap "$TEMP_SET" "$IPSET"; then
    ipset destroy "$TEMP_SET"
else
    echo "⚠️ Ошибка замены наборов, копируем вручную" >> "$LOG"
    ipset flush "$IPSET"
    ipset list "$TEMP_SET" | grep -E '^[0-9]' | while read -r ip; do
        ipset add "$IPSET" "$ip"
    done
    ipset destroy "$TEMP_SET"
fi

echo "=== Итог ===" >> "$LOG"
ipset list "$IPSET" | grep -E 'Number of entries|Members' >> "$LOG"
echo "Обновлено: $(ipset list "$IPSET" | grep 'Number of entries' | awk '{print $4}') IP-адресов"
