import 'dart:typed_data';

import 'package:fleet_flutter/collection_extensions.dart';
import 'package:fleet_flutter/fleet/fleet_element.dart';
import 'package:fleet_flutter/fleet/fleet_element_factory.dart';
import 'package:fleet_flutter/layer/layer_settings.dart';
import 'package:fleet_flutter/share/capture_service.dart';
import 'package:fleet_flutter/share/share_dialog.dart';
import 'package:fleet_flutter/share/share_link_generator.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// FleetPageのBLoC
class FleetPageBloc {
  FleetPageBloc(
    List<FleetElement>? existingElements,
    this._factory,
    this._captureService,
    this._shareLinkGenerator,
  ) {
    final initial = existingElements ?? [_factory.createText(_initialText)];
    _elements.value = initial;
  }

  //  初期表示のテキスト
  static const _initialText = 'Fleetを使ってみましょう!';

  final FleetElementFactory _factory;
  final CaptureService _captureService;
  final ShareLinkGenerator _shareLinkGenerator;

  final _elements = BehaviorSubject<List<FleetElement>>.seeded(const []);
  final _focusedIndex = BehaviorSubject<int?>.seeded(null);
  final _layerDialogRequested = PublishSubject<LayerSettings>();
  final _shareDialogRequested = PublishSubject<ShareDialogArgs>();

  //  フォーカス時の並び順の固定が有効かどうか
  bool _isOrderPinningEnabled = false;

  /// Fleetの要素リスト
  Stream<List<FleetElement>> get elements => _elements.stream;

  /// フォーカス中のFleet要素のインデックス
  /// (未選択時はnull)
  Stream<int?> get focusedIndex => _focusedIndex.stream;

  /// レイヤダイアログの表示要求を通知するStream
  Stream<LayerSettings> get layerDialogRequested =>
      _layerDialogRequested.stream;

  /// 共有ダイアログの表示要求を通知するStream
  Stream<ShareDialogArgs> get shareDialogRequested =>
      _shareDialogRequested.stream;

  /// Fleet要素のフォーカスが要求されたとき。
  void onFocusRequested(int? index) {
    //  フォーカス解除が要求された場合
    if (index == null) {
      _focusedIndex.value = null;
      return;
    }

    //  フォーカスが要求された場合
    _focusedIndex.value = index;

    //  設定に応じて、フォーカス対象のFleet要素を最前面表示にする。
    final shouldReorder = !_isOrderPinningEnabled;
    if (shouldReorder) {
      final elements = _elements.value;
      final updatedElements = elements.toTail(index);

      _elements.value = updatedElements;
    }
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

  /// レイヤメニュー項目がタップされたとき。
  void onLayerMenuTapped() {
    final focusedIndex = _focusedIndex.value;
    final focusedId =
        focusedIndex != null ? _elements.value[focusedIndex].id : null;
    final currentSettings =
        LayerSettings(_isOrderPinningEnabled, focusedId, _elements.value);

    _layerDialogRequested.add(currentSettings);
  }

  /// レイヤ設定が更新されたとき。
  void onLayerSettingsUpdated(LayerSettings result) {
    _isOrderPinningEnabled = result.isOrderPinningEnabled;
    _focusedIndex.value = result.focusedIndex;
    _elements.value = result.elements;
  }

  /// キャプチャメニュー項目がタップされたとき。
  Future<void> onCaptureMenuTapped(GlobalKey key) async {
    //  キャプチャ画像と共有リンクを生成してダイアログの表示要求を投げる。
    final image = await _captureService.capture(key);
    final link = _shareLinkGenerator.generate(_elements.value);
    final args = ShareDialogArgs(image, link);

    _shareDialogRequested.add(args);
  }

  /// 終了処理を行う。
  void dispose() {
    _elements.close();
    _focusedIndex.close();
    _layerDialogRequested.close();
    _shareDialogRequested.close();
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
