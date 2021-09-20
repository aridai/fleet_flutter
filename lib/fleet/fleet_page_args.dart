import 'package:fleet_flutter/fleet/fleet_element.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fleet_page_args.freezed.dart';

/// FleetPageの引数
@freezed
class FleetPageArgs with _$FleetPageArgs {
  /// 新規作成モード
  const factory FleetPageArgs.newly() = Newly;

  /// 編集モード
  const factory FleetPageArgs.edit({
    required List<FleetElement> existingElements,
  }) = Edit;
}
