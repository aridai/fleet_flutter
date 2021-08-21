import 'package:fleet_flutter/my_app.dart';
import 'package:fleet_flutter/output_view.dart';
import 'package:flutter/material.dart';

void main() {
  WebOutputView.init();

  //  ↓ ここに余計なスペースを入れてみる。
  runApp( MyApp());
}
