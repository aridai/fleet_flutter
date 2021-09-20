import 'package:fleet_flutter/fleet/fleet_element_factory.dart';
import 'package:fleet_flutter/share/capture_service.dart';
import 'package:fleet_flutter/share/share_link_generator.dart';
import 'package:get_it/get_it.dart';

/// DIコンテナのラッパ
abstract class Dependency {
  static Dependency? instance = _GetItContainer();

  /// 初期設定を行う。
  static void setup() {
    instance!.setupDependencies();
  }

  /// 依存関係を解決する。
  static T resolve<T extends Object>({String? name}) =>
      instance!.resolveDependency<T>(name: name);

  /// 依存関係の初期設定を行う。
  void setupDependencies();

  /// 依存関係を解決する。
  T resolveDependency<T extends Object>({String? name});
}

//  get_itでの実装
class _GetItContainer implements Dependency {
  @override
  void setupDependencies() {
    GetIt.instance.registerSingleton(FleetElementFactory());
    GetIt.instance.registerSingleton(CaptureService());
    GetIt.instance.registerSingleton(ShareLinkGenerator());
  }

  @override
  T resolveDependency<T extends Object>({String? name}) =>
      GetIt.instance.get<T>(instanceName: name);
}
