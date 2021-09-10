import 'package:fleet_flutter/emoji/native_emoji_view.dart';
import 'package:flutter/material.dart';

/// 絵文字選択UI (仮)
class EmojiPicker extends StatelessWidget {
  static const _emojiList = [
    EmojiData('🍣', '寿司'),
    EmojiData('🍖', '肉'),
    EmojiData('🐤', '鳥'),
    EmojiData('🐥', 'チンチン鳥'),
    EmojiData('😋', 'ぺろ'),
    EmojiData('😤', '圧倒的成長'),
    EmojiData('🥺', 'ぴぇん'),
    EmojiData('😫', '進捗を出してしまったぁ'),
    EmojiData('😄', 'ナンチャッテ'),
    EmojiData('🧠', '脳'),
    EmojiData('🫀', '心臓'),
    EmojiData('🫁', '肺'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('絵文字選択')),
      body: ListView.builder(
        itemCount: _emojiList.length,
        itemBuilder: (context, index) {
          final data = _emojiList[index];

          return SizedBox(
            height: 48,
            child: ListTile(
              leading: NativeEmojiView(
                emoji: data.emoji,
                capturable: false,
                size: 32,
              ),
              title: Text(data.name),
              onTap: () => Navigator.pop(context, data.emoji),
            ),
          );
        },
      ),
    );
  }
}

class EmojiData {
  const EmojiData(this.emoji, this.name);

  final String emoji;
  final String name;
}
