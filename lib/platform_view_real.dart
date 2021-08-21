import 'dart:ui' as ui;

import 'package:universal_html/html.dart';

void registerViewFactoryImpl(String viewType, HtmlElement factory(int viewId)) {
  //// ignore: undefined_prefixed_name, avoid_dynamic_calls
  ui.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) => factory(viewId),
  );
}
