import 'dart:typed_data';
import 'dart:ui';

import 'package:fleet_flutter/collection_extensions.dart';
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
    //  フォーカスが解除された場合
    if (index == null) {
      _focusedIndex.value = null;
      return;
    }

    //  フォーカスが要求された場合
    //  (対象要素を末尾に並び替える。)
    final elements = _elements.value;
    final lastIndex = elements.length - 1;
    final updatedElements = elements.toTail(index);

    _elements.value = updatedElements;
    _focusedIndex.value = lastIndex;
  }

  /// Fleet要素に対する操作が行われたとき。
  void onElementInteracted(
    int index,
    Offset translationDelta,
    double scaleDelta,
    double rotationDelta,
  ) {
    final elements = _elements.value;
    final element = elements[index];
    final updatedPos = element.pos + translationDelta;
    final updatedScale = element.scale * scaleDelta;
    final updatedAngle = element.angleInRad + rotationDelta;

    final updatedElement = element.copyWith(
      pos: updatedPos,
      scale: updatedScale,
      angleInRad: updatedAngle,
    );
    final updatedElements = elements.replace(index, updatedElement);
    _elements.value = updatedElements;
  }

  /// テキストが入力されたとき。
  void onTextEntered(int? index, String text) {
    //  新規にテキストが追加されたとき。
    if (index == null) {
      final element = _factory.createText(text);
      _addNewElement(element);
    }

    //  既存要素に対してテキストが入力されたとき。
    else {
      //  TODO
    }
  }

  /// 絵文字が選択されたとき。
  void onEmojiPicked(String emoji) {
    //  新たに絵文字要素を追加する。
    final element = _factory.createEmoji(emoji);
    _addNewElement(element);
  }

  /// 画像が選択されたとき。
  void onImagePicked(String fileName, Uint8List imageBytes) {
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
    final updatedElements = elements.append(element);
    final lastIndex = updatedElements.length - 1;

    //  UIに反映させ、フォーカスがあたった状態にする。
    _elements.value = updatedElements;
    _focusedIndex.value = lastIndex;
  }
}
