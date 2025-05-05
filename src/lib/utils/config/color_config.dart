import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:toml/toml.dart';
import 'package:flutter/material.dart';

class ColorConfig {
  late Map<String, dynamic> _config;

  ColorConfig._privateConstructor();

  static final ColorConfig _instance = ColorConfig._privateConstructor();

  factory ColorConfig() {
    return _instance;
  }

  Future<void> loadConfig() async {
    final String tomlString = await rootBundle.loadString('lib/assets/colors.toml');
    _config = TomlDocument.parse(tomlString).toMap();
  }

  Color getColor(String mode, String color) {
    final colorHex = _config['colors'][mode][color] as String;
    return _hexToColor(colorHex);
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
