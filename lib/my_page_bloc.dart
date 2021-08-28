import 'dart:ui';

import 'package:fleet_flutter/fleet_element.dart';
import 'package:rxdart/rxdart.dart';

/// MyPageのBLoC
class MyPageBloc {
  final _elements = BehaviorSubject<List<FleetElement>>.seeded(
    [
      const FleetElement.text('FleetFlutter', Offset(0, -150), 1.5, 0.0),
      const FleetElement.text('Flutterで', Offset(0, -100), 1.5, 0.0),
      const FleetElement.text('Fleetみたいなやつを', Offset(0, -50), 1.5, 0.0),
      const FleetElement.text('つくってみた', Offset(0, 0), 1.5, 0.0),
      const FleetElement.text('🍣', Offset(0, 50), 1.5, 0.0),
      const FleetElement.text('㊗️日本語も使えます🎉', Offset(0, 100), 1.5, 0.0),
    ],
  );

  final _focusedIndex = BehaviorSubject<int?>.seeded(null);

  /// Fleetの要素リスト
  Stream<List<FleetElement>> get elements => _elements.stream;

  /// フォーカス中のFleet要素のインデックス
  /// (未選択時はnull)
  Stream<int?> get focusedIndex => _focusedIndex.stream;

  /// Fleet要素がタップされたとき。
  void onFocusRequested(int? index) {
    _focusedIndex.add(index);
  }

  /// Fleet要素に対する操作が行われたとき。
  void onInteracted(
    int index,
    Offset translationDelta,
    double scaleDelta,
    double rotationDelta,
  ) {
    final element = _elements.value[index];
    final updatedPos = element.pos + translationDelta;
    final updatedScale = element.scale * scaleDelta;
    final updatedAngle = element.angleInRad + rotationDelta;

    final updatedElement = element.copyWith(
      pos: updatedPos,
      scale: updatedScale,
      angleInRad: updatedAngle,
    );
    final updatedElements = List.generate(
      _elements.value.length,
      (i) => i == index ? updatedElement : _elements.value[i],
    );
    _elements.value = updatedElements;
  }

  /// 終了処理を行う。
  void dispose() {
    _elements.close();
    _focusedIndex.close();
  }
}
