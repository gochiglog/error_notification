#!/usr/bin/env bash

# 正常終了・エラー共に通知を送るバージョン
# （trap EXIT のみ使用 ＋ set -eでコマンド失敗時に即終了する）

set -e  # コマンドが失敗したら即スクリプトを終了する

trap 'on_exit' EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."

if [ -f "${PROJECT_ROOT}/resources/.env" ]; then
  source "${PROJECT_ROOT}/resources/.env"
else
  echo "[ERROR] .env file not found in resources/."
  exit 1
fi

LOG_FILE="${PROJECT_ROOT}/logs/error_monitor.log"

on_exit() {
  local exit_code=$?
  local line_no=$LINENO  # ここでは終了時点の行番号になる

  if [ "${exit_code}" -eq 0 ]; then
    # 成功時のメッセージ
    local message="Success: $(basename "$0") exited normally (exit code: 0)."
  else
    # 失敗時のメッセージ
    local message="Error: $(basename "$0") exited at line ${line_no} with code ${exit_code}."
  fi

  # ログに出力
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> "${LOG_FILE}"

  # LINEに送信 (Messaging API)
  send_line_message "${message}"
}

send_line_message() {
  local text="$1"
  local line_api_url="https://api.line.me/v2/bot/message/push"
  local payload=$(cat << EOF
{
  "to": "${LINE_USER_ID}",
  "messages": [
    {
      "type": "text",
      "text": "${text}"
    }
  ]
}
EOF
)
  curl -s -X POST "${line_api_url}" \
       -H "Content-Type: application/json" \
       -H "Authorization: Bearer ${LINE_CHANNEL_ACCESS_TOKEN}" \
       -d "${payload}"
}

# ----------------------
# テスト用：コマンドを書く
# 成功パターンを試す：正常終了するコマンド
echo "Hello, success!"

# 失敗パターンを試すにはコメントアウトを外す
# ls /this_directory_should_not_exist  # エラーを発生させる行

echo "=== script end ==="
