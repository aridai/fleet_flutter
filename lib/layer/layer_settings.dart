import 'package:fleet_flutter/fleet/fleet_element.dart';

/// レイヤ設定
class LayerSettings {
  const LayerSettings(
    this.isOrderPinningEnabled,
    this.focusedId,
    this.elements,
  );

  /// 並び順の固定が有効化どうか
  final bool isOrderPinningEnabled;

  /// フォーカスされているFleet要素のID
  /// (未フォーカス時はnull)
  final int? focusedId;

  /// Fleet要素のリスト
  final List<FleetElement> elements;

  /// フォーカスされているFleet要素のインデックス
  /// (未フォーカス時はnull)
  int? get focusedIndex =>
      focusedId != null ? elements.indexWhere((e) => e.id == focusedId) : null;
}
