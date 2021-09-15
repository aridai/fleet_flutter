import 'dart:typed_data';
import 'dart:ui';

import 'package:fleet_flutter/fleet_element.dart';
import 'package:fleet_flutter/fleet_element_factory.dart';
import 'package:rxdart/rxdart.dart';

/// MyPageのBLoC
class MyPageBloc {
  MyPageBloc(this._factory) {
    _elements.value = [_factory.createText('Fleetを使ってみましょう!')];
  }

  final FleetElementFactory _factory;

  final _elements = BehaviorSubject<List<FleetElement>>.seeded(const []);
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

  /// 絵文字が選択されたとき。
  void onEmojiSelected(String emoji) {
    //  新たに絵文字要素を追加する。
    final element = _factory.createEmoji(emoji);
    _addNewElement(element);
  }

  /// 画像が選択されたとき。
  void onImageSelected(String fileName, Uint8List imageBytes) {
    //  新たに画像要素を追加する。
    final element = _factory.createImage(fileName, imageBytes);
    _addNewElement(element);
  }

  /// 終了処理を行う。
  void dispose() {
    _elements.close();
    _focusedIndex.close();
  }

  //  新しい要素を追加をUIに反映させる。
  //  (その要素にフォーカスがあたった状態になる。)
  void _addNewElement(FleetElement element) {
    //  既存の要素リストの末尾に新しい要素を使える。
    final elements = _elements.value;
    final size = elements.length + 1;
    final lastIndex = size - 1;
    final updatedElements =
        List.generate(size, (i) => i != lastIndex ? elements[i] : element);

    //  UIに反映させ、フォーカスがあたった状態にする。
    _elements.value = updatedElements;
    _focusedIndex.value = lastIndex;
  }
}
