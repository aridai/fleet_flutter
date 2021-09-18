import 'dart:typed_data';
import 'dart:ui';

import 'package:fleet_flutter/collection_extensions.dart';
import 'package:fleet_flutter/fleet_element.dart';
import 'package:fleet_flutter/fleet_element_factory.dart';
import 'package:fleet_flutter/layer/layer_settings.dart';
import 'package:rxdart/rxdart.dart';

/// MyPageのBLoC
class MyPageBloc {
  MyPageBloc(this._factory) {
    _elements.value = [_factory.createText('Fleetを使ってみましょう!')];
  }

  final FleetElementFactory _factory;

  final _elements = BehaviorSubject<List<FleetElement>>.seeded(const []);
  final _focusedId = BehaviorSubject<int?>.seeded(null);

  //  フォーカス時の並び順の固定が有効かどうか
  bool _isOrderPinningEnabled = false;

  /// Fleetの要素リスト
  Stream<List<FleetElement>> get elements => _elements.stream;

  /// フォーカス中のFleet要素のID
  /// (未選択時はnull)
  Stream<int?> get focusedId => _focusedId.stream;

  /// レイヤ設定
  LayerSettings get layerSettings =>
      LayerSettings(_isOrderPinningEnabled, _focusedId.value, _elements.value);

  /// Fleet要素のフォーカスが要求されたとき。
  void onFocusRequested(FleetElement? element) {
    //  フォーカス解除が要求された場合
    if (element == null) {
      _focusedId.value = null;
      return;
    }

    //  フォーカスが要求された場合
    _focusedId.value = element.id;

    //  設定に応じて、フォーカス対象のFleet要素を最前面表示にする。
    final shouldReorder = !_isOrderPinningEnabled;
    if (shouldReorder) {
      final elements = _elements.value;
      final index = elements.indexWhere((e) => e.id == element.id);
      final updatedElements = elements.toTail(index);

      _elements.value = updatedElements;
    }
  }

  /// Fleet要素に対する操作が行われたとき。
  void onElementInteracted(
    FleetElement element,
    Offset translationDelta,
    double scaleDelta,
    double rotationDelta,
  ) {
    final elements = _elements.value;
    final index = elements.indexWhere((e) => e.id == element.id);
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

  /// レイヤ設定が更新されたとき。
  void onLayerSettingsUpdated(LayerSettings result) {
    _isOrderPinningEnabled = result.isOrderPinningEnabled;
    _focusedId.value = result.focusedId;
    _elements.value = result.elements;
  }

  /// 終了処理を行う。
  void dispose() {
    _elements.close();
    _focusedId.close();
  }

  //  新しい要素を追加をUIに反映させる。
  //  (その要素にフォーカスがあたった状態になる。)
  void _addNewElement(FleetElement element) {
    //  既存の要素リストの末尾に新しい要素を使える。
    final elements = _elements.value;
    final updatedElements = elements.append(element);

    //  UIに反映させ、フォーカスがあたった状態にする。
    _elements.value = updatedElements;
    _focusedId.value = element.id;
  }
}
