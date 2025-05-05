import 'package:stock_overflow/data/services/local_storage_service.dart';
import 'package:stock_overflow/data/services/secure_storage_service.dart';
import 'package:stock_overflow/utils/config/currency_config.dart';

class SettingsData {
  final LocalStorageService _localStorageService = LocalStorageService();
  final SecureStorageService _secureStorageService = SecureStorageService();
  final CurrencyConfig _currencyConfig = CurrencyConfig();

  Future<void> loadCurrencyConfig() async {
    await _currencyConfig.loadConfig();
  }

  Future<String?> getCurrency() async {
    return await _localStorageService.readData('currency') as String?;
  }

  Future<bool?> getDarkMode() async {
    return await _localStorageService.readData('isDarkMode') as bool?;
  }

  Future<void> setCurrency(String currency) async {
    await _localStorageService.writeData('currency', currency);
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    await _localStorageService.writeData('isDarkMode', isDarkMode);
  }

  Future<String?> getApiKey() async {
    return await _secureStorageService.readSecureData('apiKey');
  }

  Future<void> setApiKey(String apiKey) async {
    await _secureStorageService.writeSecureData('apiKey', apiKey);
  }

  Map<String, String> get currencyMap => _currencyConfig.currencyMap;
  List<String> get currencyList => _currencyConfig.currencyList;
}
