import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:toml/toml.dart';

class CurrencyConfig {
  late Map<String, String> _currencyMap;
  late Map<String, String> _currencySymbols;

  CurrencyConfig._privateConstructor();

  static final CurrencyConfig _instance = CurrencyConfig._privateConstructor();

  factory CurrencyConfig() {
    return _instance;
  }

  Future<void> loadConfig() async {
    final String tomlString = await rootBundle.loadString('lib/assets/currencies.toml');
    final Map<String, dynamic> config = TomlDocument.parse(tomlString).toMap();
    _currencyMap = (config['currencies'] as Map<String, dynamic>).map((key, value) => MapEntry(key, value['code'] as String));
    _currencySymbols = (config['currencies'] as Map<String, dynamic>).map((key, value) => MapEntry(key, value['symbol'] as String));
  }

  Map<String, String> get currencyMap => _currencyMap;
  List<String> get currencyList => _currencyMap.values.toList();

  String getCurrencySymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? currencyCode;
  }
}
