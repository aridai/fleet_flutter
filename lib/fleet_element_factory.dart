import 'dart:typed_data';

import 'package:fleet_flutter/fleet_element.dart';
import 'package:flutter/material.dart';

/// Fleet要素のファクトリ
class FleetElementFactory {
  static const _defaultPos = Offset(0, 0);
  static const _defaultScale = 1.0;
  static const _defaultAngle = 0.0;

  //  カウンタ
  //  (連番IDを発行するため。)
  int _count = 0;

  /// テキスト要素を生成する。
  FleetTextElement createText(String text) {
    final id = _count++;
    final element = FleetElement.text(
      id,
      text,
      _defaultPos,
      _defaultScale,
      _defaultAngle,
    );

    return element as FleetTextElement;
  }

  /// 絵文字要素を生成する。
  FleetEmojiElement createEmoji(String emoji) {
    final id = _count++;
    final element = FleetElement.emoji(
      id,
      emoji,
      _defaultPos,
      _defaultScale,
      _defaultAngle,
    );

    return element as FleetEmojiElement;
  }

  /// 画像要素を生成する。
  FleetImageElement createImage(String fileName, Uint8List imageBytes) {
    final id = _count++;
    final element = FleetElement.image(
      id,
      fileName,
      imageBytes,
      _defaultPos,
      _defaultScale,
      _defaultAngle,
    );

    return element as FleetImageElement;
  }
}
