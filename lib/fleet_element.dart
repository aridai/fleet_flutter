import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'fleet_element.freezed.dart';

/// Fleet要素
@freezed
class FleetElement with _$FleetElement {
  /// テキスト要素
  const factory FleetElement.text(
    String text,
    Offset pos,
    double scale,
    double angleInRad,
  ) = FleetTextElement;

  /// 絵文字要素
  const factory FleetElement.emoji(
    String emoji,
    Offset pos,
    double scale,
    double angleInRad,
  ) = FleetEmojiElement;

  /// 画像要素 (仮)
  const factory FleetElement.image(
    Offset pos,
    double scale,
    double angleInRad,
  ) = FleetImageElement;
}
