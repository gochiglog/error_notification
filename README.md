# error_notification

Bashスクリプトを利用して、任意のコマンドやスクリプト（例：Pythonなど）の実行結果が「成功したか／失敗したか」をLINEに通知するプロジェクトです。 

``plaintext  
　　　　　　　　　　　　　　　　　　　　　　　　　　┌─────────────────────────────────────┐┌────────────────────────────────────────────┐
│ (A) Webhook Handling                 ││ (B) Error Notification                     │
│  linebot_webhook_handler (Lambda)  　││  notify_error (Lambda)                     │
└──────────────────────────────────────┘└────────────────────────────────────────────┘
       [User's LINE BOT] (友だち追加)                    [User's PC] (エラー発生)
                   |                                               |
                   v                                               v
        +----------------------------+                 +----------------------------+
        |  API Gateway (/webhook)   |                 |  API Gateway (/notifyError)|
        +----------------------------+                 +----------------------------+
                   |                                               |
                   v                                               v
[ linebot_webhook_handler (Lambda) ]                [ notify_error (Lambda) ]
 - followイベント受信→DynamoDBに userId保存             - userId & errorMsg を受け取り
                                                       - LINE へ Push 通知
                   |                                               |
                   v                                               v
               [DynamoDB]                                    [User's LINE BOT]
```
---
## 概要

- **目的**: 実行したコマンドが正常終了したか、エラーで終了したかを自動で検知し、LINEでメッセージを受け取れるようにする。  
- **主なファイル**:  
  - `bin/wrapper.sh`  
    - ラップ用スクリプト。ここにコマンド（例：`python script.py`）を渡して実行すると、成功／失敗の判定を行ってLINEに通知します。  
  - `resources/.env.sample`  
    - LINE Messaging APIのトークンやユーザIDを設定するためのサンプルファイル。  
  - `logs/error_monitor.log`  
    - ログを記録するファイル。成功・失敗の結果が追記されます。

---

## セットアップ手順
1. **リポジトリのクローンまたはダウンロード**  
```bash
git clone https://github.com/gochiglog/error_notification.git
```
2. **ユーザが Bot を友だち追加**
 - ![image](https://github.com/user-attachments/assets/a0eb7f8c-d986-4749-b92d-ad0cc6303224)
 - Bot が「あなたのIDは Uxxxxxx です」というメッセージを返信

3. **依存コマンドの確認**    
このスクリプトは、HTTPリクエスト送信のために curl を使用します。
macOS/Linux、あるいはWindowsのGit Bashなら通常は curl が同梱されています。

4. **依存コマンドの確認**   
 - `resources/` ディレクトリ内に `.env.sample` というサンプルファイルがあります。これを `.env` という名前でコピーし、中身を編集してください。
```bash
cp resources/.env.sample resources/.env
```
 - resources/.env を開き、先ほどBotから教えてもらったIDを設定してください。
```bash
LINE_USER_ID="Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

5. **スクリプトに実行権限を付与**  
```bash
chmod +x bin/wrapper.sh
```

6. **テスト実行**  
 - 正常に終わるコマンド（例：echo "Hello"）をラップして実行:
```bash
./error_notification/bin/wrapper.sh echo "Hello"
```
 - あえて失敗するコマンド(存在しないディレクトリ参照):
 ```bash
 ./error_notification/bin/wrapper.sh ls /non_exit_dir
 ```

6. **実際の使用方法** 
↓のようにし、実行します
```bash
./error_notification/bin/wrapper.sh [実行したいコマンド(.pyなど)]
```

7. **ディレクトリ構成** 
```pgsql
error_notification/
├─ bin/
│   └─ wrapper.sh          # コマンドをラップするメインスクリプト
├─ resources/
│   ├─ .env.sample         # サンプル環境変数ファイル
├─ logs/
│   └─ error_monitor.log   # 成功・失敗の結果を追記するログ
├─ .gitignore
└─ README.md
```

 

