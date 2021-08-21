import 'package:fleet_flutter/platform_view_fake.dart'
    if (dart.library.html) 'package:fleet_flutter/platform_view_real.dart';
import 'package:universal_html/html.dart';

/// 「platformViewRegistry.registerViewFactory」のラッパ
void registerViewFactory(String viewType, HtmlElement factory(int viewId)) {
  registerViewFactoryImpl(viewType, factory);
}
