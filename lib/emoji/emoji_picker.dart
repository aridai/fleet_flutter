import 'package:fleet_flutter/emoji/native_emoji_view.dart';
import 'package:flutter/material.dart';

class EmojiPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final emojiList = List.generate(256, (i) => '🍣');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '絵文字選択',
          style: TextStyle(
            fontFamilyFallback: ['SawarabiGothic', 'NotoColorEmoji'],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: emojiList.length,
        itemBuilder: (context, index) => ListTile(
          title: NativeEmojiView(
            emoji: emojiList[index],
            capturable: false,
            size: 64,
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
