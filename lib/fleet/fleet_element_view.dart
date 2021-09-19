import 'package:fleet_flutter/emoji/native_emoji_view.dart';
import 'package:fleet_flutter/fleet/fleet_element.dart';
import 'package:flutter/material.dart';

/// Fleet要素のView
class FleetElementView extends StatelessWidget {
  const FleetElementView({
    Key? key,
    required this.element,
    required this.isFocused,
    required this.onFocusRequested,
  }) : super(key: key);

  //  デフォルトの絵文字要素のサイズ
  static const _defaultEmojiSize = 32.0;

  /// Fleet要素
  final FleetElement element;

  /// フォーカスがあたっているかどうか
  final bool isFocused;

  /// フォーカスが要求されたときのコールバック
  final VoidCallback onFocusRequested;

  //  フォーカス時のDecoration (枠表示あり)
  static final _focusedDecoration = BoxDecoration(
    border: Border.all(
      color: Colors.grey,
      width: 1,
      style: BorderStyle.solid,
    ),
  );

  //  非フォーカス時のDecoration (枠表示なし)
  static final _unfocusedDecoration = BoxDecoration(
    border: Border.all(
      color: Colors.transparent,
      width: 1,
      style: BorderStyle.solid,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final decoration = isFocused ? _focusedDecoration : _unfocusedDecoration;
    final matrix = Matrix4.identity()
      ..translate(element.pos.dx, element.pos.dy)
      ..rotateZ(element.angleInRad)
      ..scale(element.scale);

    return Align(
      alignment: Alignment.center,
      child: Container(
        transform: matrix,
        transformAlignment: Alignment.center,
        decoration: decoration,
        child: GestureDetector(
          onTap: _onTap,
          child: _buildContent(),
        ),
      ),
    );
  }

  //  コンテンツ部分を生成する。
  Widget _buildContent() {
    return element.map(
      text: (textElement) => Text(textElement.text),
      emoji: (emojiElement) => NativeEmojiView(
        emoji: emojiElement.emoji,
        size: _defaultEmojiSize,
      ),
      image: (imageElement) => Image.memory(imageElement.imageBytes),
    );
  }

  //  タップ時
  void _onTap() {
    //  未フォーカスの場合、フォーカスを要求する。
    if (!isFocused) onFocusRequested();
  }
}
