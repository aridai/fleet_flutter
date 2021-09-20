import 'package:fleet_flutter/dependency.dart';
import 'package:fleet_flutter/my_app.dart';
import 'package:fleet_flutter/share/output_view.dart';
import 'package:flutter/material.dart';

void main() {
  Dependency.setup();
  WebOutputView.init();

  final app = MyApp(Dependency.resolve());
  runApp(app);
}
