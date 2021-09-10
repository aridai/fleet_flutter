import 'dart:collection';
import 'dart:typed_data';

class EmojiStore {
  final _emojiImageMap = HashMap<String, Uint8List>();

  Uint8List? getEmojiImage(String emoji) => _emojiImageMap[emoji];

  void saveEmojiImage(String emoji, Uint8List emojiImage) =>
      _emojiImageMap[emoji] = emojiImage;
}
