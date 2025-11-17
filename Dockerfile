# docker pull ubuntu:22.04
# ベースのコンテナイメージ
FROM ubuntu:20.04

# 非対話モード（tzdata の入力防止）
ENV DEBIAN_FRONTEND=noninteractive

# ユーザ変更
USER root

# コンテナイメージ作成時に実行するRUN
# 空のイメージにパッケージを追加
# パッケージ更新 & Python 3.9 + ビルドに必要な依存パッケージを追加
RUN apt update && apt install -y \
    python3.9 python3.9-distutils python3-pip \
    build-essential \
    python3.9-dev \
    libffi-dev \
    libssl-dev \
    wget \
    && apt clean

# ローカルの情報をコンテナ側にコピーする(remote上のファイルは扱えない)
# 圧縮ファイルもそのままコピー
COPY requirements.txt .
# pip アップグレード
RUN python3.9 -m pip install --upgrade pip

# ライブラリインストール
RUN python3.9 -m pip install -r requirements.txt

# コンテナ側の環境変数
ENV SITE_DOMAIN=vtuber.supu.com

# コンテナ側の作業ディレクトリを変更
WORKDIR /var

# コンテナ側にファイルを追加(リモート上のファイルも扱える)
# 圧縮ファイルが自動解凍
ADD https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data .

# エントリーポイントの設定
# コンテナ実行時に動かしたいシェルコマンドを指定
COPY script.py .
ENTRYPOINT ["python3.9", "script.py"]