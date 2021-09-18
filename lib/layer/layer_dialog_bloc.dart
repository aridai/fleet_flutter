import 'package:fleet_flutter/collection_extensions.dart';
import 'package:fleet_flutter/fleet_element.dart';
import 'package:fleet_flutter/layer/layer_settings.dart';
import 'package:rxdart/rxdart.dart';

/// レイヤダイアログのBLoC
class LayerDialogBloc {
  LayerDialogBloc(LayerSettings settings) {
    _isPinningEnabled = BehaviorSubject.seeded(settings.isOrderPinningEnabled);
    _focusedId = BehaviorSubject.seeded(settings.focusedId);
    _list = BehaviorSubject.seeded(settings.elements);
  }

  late final BehaviorSubject<bool> _isPinningEnabled;
  late final BehaviorSubject<int?> _focusedId;
  late final BehaviorSubject<List<FleetElement>> _list;

  /// 並び順の固定が有効かどうかの初期値
  bool get initialIsLockEnabled => _isPinningEnabled.value;

  /// フォーカスされているFleet要素のIDの初期値
  int? get initialFocusedId => _focusedId.value;

  /// Fleet要素リストの初期値
  List<FleetElement> get initialList => _list.value;

  /// 並び順ロックが有効かどうか
  Stream<bool> get isLockEnabled => _isPinningEnabled.stream;

  /// フォーカスされている要素のID
  Stream<int?> get focusedId => _focusedId.stream;

  /// Fleet要素リスト
  Stream<List<FleetElement>> get list => _list.stream;

  /// 現在最新のレイヤ設定
  LayerSettings get currentSettings =>
      LayerSettings(_isPinningEnabled.value, _focusedId.value, _list.value);

  /// 並び順固定スイッチが変更されたとき。
  void onOrderPinningSwitchChanged(bool isEnabled) {
    _isPinningEnabled.value = isEnabled;
  }

  /// セルがタップされたとき。
  void onLayerCellTapped(FleetElement element) {
    //  すでにフォーカス済みである要素がタップされた場合はフォーカスを外し、
    //  そうではない場合は場合はタップされた要素にフォーカスを設定する。
    final isAlreadyFocused = _focusedId.value == element.id;
    final updatedFocusedId = isAlreadyFocused ? null : element.id;

    _focusedId.value = updatedFocusedId;
  }

  /// 並び替えが行われたとき。
  void onReorder(int oldIndex, int newIndex) {
    final oldList = _list.value;
    final newList = oldList.reorder(oldIndex, newIndex);
    _list.value = newList;
  }

  /// 終了処理を行う。
  void dispose() {
    _isPinningEnabled.close();
    _focusedId.close();
    _list.close();
  }
}
