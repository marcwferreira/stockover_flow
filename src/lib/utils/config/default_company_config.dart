import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:toml/toml.dart';
import 'package:stock_overflow/data/models/company.dart';

class DefaultCompanyConfig {
  late List<Company> _companies;

  DefaultCompanyConfig._privateConstructor();

  static final DefaultCompanyConfig _instance = DefaultCompanyConfig._privateConstructor();

  factory DefaultCompanyConfig() {
    return _instance;
  }

  Future<void> loadConfig() async {
    try {
      final String tomlString = await rootBundle.loadString('lib/assets/defaultCompanies.toml');
      final config = TomlDocument.parse(tomlString).toMap();
      _companies = _parseCompanies(config['companies']);
    } catch (e) {
      rethrow;
    }
  }

  List<Company> get companies => _companies;

  List<Company> _parseCompanies(List<dynamic> companyList) {
    return companyList.map((company) {
      return Company(
        id: company['id'],
        symbol: company['symbol'],
        name: company['name'],
        type: company['type'],
        value: company['value'],
        isFollowing: false,
      );
    }).toList();
  }
}
