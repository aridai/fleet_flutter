import 'dart:typed_data';
import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'fleet_element.freezed.dart';

/// Fleet要素
@freezed
class FleetElement with _$FleetElement {
  /// テキスト要素
  const factory FleetElement.text(
    int id,
    String text,
    Offset pos,
    double scale,
    double angleInRad,
  ) = FleetTextElement;

  /// 絵文字要素
  const factory FleetElement.emoji(
    int id,
    String emoji,
    Offset pos,
    double scale,
    double angleInRad,
  ) = FleetEmojiElement;

  /// 画像要素
  const factory FleetElement.image(
    int id,
    String fileName,
    Uint8List imageBytes,
    Offset pos,
    double scale,
    double angleInRad,
  ) = FleetImageElement;
}
