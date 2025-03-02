# error_notification

Bashスクリプトを利用して、任意のコマンドやスクリプト（例：Pythonなど）の実行結果が「成功したか／失敗したか」をLINEに通知するプロジェクトです。  

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
git clone https://github.com/YourUsername/error_notification.git
```

2. **依存コマンドの確認**    
このスクリプトは、HTTPリクエスト送信のために curl を使用します。
macOS/Linux、あるいはWindowsのGit Bashなら通常は curl が同梱されています。

3. **依存コマンドの確認**   
 - `resources/` ディレクトリ内に `.env.sample` というサンプルファイルがあります。これを `.env` という名前でコピーし、中身を編集してください。
```bash
cp resources/.env.sample resources/.env
```
 - resources/.env を開き、下記2つの値を設定します。
```bash
LINE_CHANNEL_ACCESS_TOKEN="あなたのLong-livedチャネルアクセストークン"
LINE_USER_ID="Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```
 - `.env` には絶対に秘密のトークンを公開しないよう注意してください。.gitignore で除外されているか確認しましょう。

4. **スクリプトに実行権限を付与**  
```bash
chmod +x bin/wrapper.sh
```

5. **テスト実行**  
 - 正常に終わるコマンド（例：echo "Hello"）をラップして実行:
```bash
./error_notification/bin/wrapper.sh ls /no_such_dir
```
 - あえて失敗するコマンド(存在しないディレクトリ参照):
 ```bash
 ./error_notification/bin/wrapper.sh ls /no_such_dir
 ```

6. **実際の使用方法** 
↓のようにし、実行します
```bash
./error_notification/bin/wrapper.sh [実行したいコマンド]
```

7. **ディレクトリ構成** 
```pgsql
error_notification/
├─ bin/
│   └─ wrapper.sh          # コマンドをラップするメインスクリプト
├─ resources/
│   ├─ .env.sample         # サンプル環境変数ファイル
│   └─ .env                # 実際の環境変数（Git管理対象外推奨）
├─ logs/
│   └─ error_monitor.log   # 成功・失敗の結果を追記するログ
├─ .gitignore
└─ README.md
```

 

