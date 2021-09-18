import 'dart:collection';
import 'dart:typed_data';

/// 絵文字の画像データのキャッシュ機構
class EmojiCacheStore {
  //  現在はキャッシュの数に上限をつけていないため、単なるHashMapで保持している。
  //  (キャッシュ数の上限を設ける場合は別のデータ構造の検討が必要)
  final _map = HashMap<String, Uint8List>();

  /// キャッシュから画像データを取得する。
  /// (存在しない場合はnullを返す。)
  Uint8List? get(String emoji) => _map[emoji];

  /// 画像データをキャッシュに保存する。
  void save(String emoji, Uint8List imageBytes) {
    _map[emoji] = imageBytes;
  }
}
