#!/usr/bin/env bash
set -e
trap 'on_exit' EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."

# .env読み込み
if [ -f "${PROJECT_ROOT}/resources/.env" ]; then
  source "${PROJECT_ROOT}/resources/.env"
else
  echo "[ERROR] .env file not found in resources/."
  exit 1
fi

LOG_FILE="${PROJECT_ROOT}/logs/error_monitor.log"

on_exit() {
  local exit_code=$?
  if [ "${exit_code}" -eq 0 ]; then
    local message="Success: Command '$*' exited with code 0."
  else
    local message="Error: Command '$*' failed with code ${exit_code}."
  fi

  # ログ記録
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> "${LOG_FILE}"

  # LINE通知（Messaging API）
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

# "$@" でユーザ指定のコマンドを丸ごと実行
"$@"
