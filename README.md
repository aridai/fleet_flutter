# fleet_flutter

Flutter製のパチもんFleetアプリ

[![CI](https://github.com/aridai/fleet_flutter/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/aridai/fleet_flutter/actions/workflows/CI.yml)
![Dart](https://img.shields.io/static/v1?label=language&message=Dart&color=00B4AB)
![Flutter](https://img.shields.io/static/v1?label=framework&message=Flutter&color=46CAF9)

## 使用ライブラリ

[使用ライブラリ 一覧](LIBRARIES.md) のページにまとめて記載しています。  
ライブラリ作者の皆様に感謝いたします。 🙏

## コマンド

* 依存関係の復元
  * `flutter pub get`
* build_runnerの実行
  * `flutter pub run build_runner build --delete-conflicting-outputs`
* ビルド (Web向け)
  * `flutter build web --web-renderer canvaskit`
* フォーマット
  * `flutter format --set-exit-if-changed ./`
* 静的解析
  * `flutter analyze`
