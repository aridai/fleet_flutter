import 'package:fleet_flutter/emoji/native_emoji_view.dart';
import 'package:fleet_flutter/fleet_element.dart';
import 'package:flutter/material.dart';

/// レイヤのリストセル
class LayerCell extends StatelessWidget {
  LayerCell({
    Key? key,
    required this.element,
    required this.isFocused,
    required this.onTap,
  }) : super(key: key);

  static const _size = 32.0;

  /// Fleetの要素
  final FleetElement element;

  /// フォーカスされているかどうか
  final bool isFocused;

  /// セルがタップされたときのコールバック
  final VoidCallback onTap;

  late final Widget _leading = element.map(
    text: (text) => const Icon(Icons.text_fields),
    emoji: (emoji) => NativeEmojiView(
      key: ValueKey(element.id),
      emoji: emoji.emoji,
      size: _size,
    ),
    image: (img) => Image.memory(img.imageBytes, width: _size, height: _size),
  );

  late final Widget _title = element.map(
    text: (text) => Text(text.text),
    emoji: (emoji) => Text('絵文字 (${_toUnicodeNotation(emoji.emoji)})'),
    image: (image) => Text(image.fileName),
  );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _leading,
      title: _title,
      //subtitle: const Text('テキスト要素'),
      selected: isFocused,
      onTap: onTap,
    );
  }

  //  絵文字をUnicode表記に変換する。
  String _toUnicodeNotation(String emoji) => emoji.runes
      .map((r) => 'U+${r.toRadixString(16).toUpperCase()}')
      .join(', ');
}
