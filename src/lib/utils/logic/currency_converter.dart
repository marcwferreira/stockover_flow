import 'dart:async';
import 'package:stock_overflow/utils/APIUtils/alphavantage_api.dart';
import 'package:stock_overflow/utils/config/currency_config.dart';
import 'package:stock_overflow/utils/logic/settings_data.dart';
import 'package:stock_overflow/data/services/local_storage_service.dart';

class CurrencyConverter {
  final AlphaVantageAPI _api = AlphaVantageAPI();
  final SettingsData _settings = SettingsData();
  final CurrencyConfig _currencyConfig = CurrencyConfig();
  final LocalStorageService _storageService = LocalStorageService();

  Future<double> _fetchExchangeRate(String fromCurrency, String toCurrency) async {
    try {
      Map<String, dynamic> exchangeRateData = await _api.fetchCurrencyExchangeRate(fromCurrency, toCurrency);
      double exchangeRate = double.parse(exchangeRateData['Realtime Currency Exchange Rate']['5. Exchange Rate']);
      DateTime now = DateTime.now();

      await _storageService.writeData('$fromCurrency-$toCurrency', {
        'exchangeRate': exchangeRate,
        'timestamp': now.toIso8601String(),
      });

      return exchangeRate;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> _getCachedExchangeRate(String fromCurrency, String toCurrency) async {
    final cachedData = await _storageService.readData('$fromCurrency-$toCurrency');

    if (cachedData != null) {
      DateTime timestamp = DateTime.parse(cachedData['timestamp']);
      DateTime now = DateTime.now();

      if (now.difference(timestamp).inHours < 4) {
        return cachedData['exchangeRate'];
      }
    }

    return await _fetchExchangeRate(fromCurrency, toCurrency);
  }

  Future<double> convertToUserCurrency(double amountInUSD) async {
    await _currencyConfig.loadConfig();
    String? userCurrency = await _settings.getCurrency();
    if (userCurrency == null || userCurrency == 'USD') {
      return amountInUSD;
    }

    try {
      double exchangeRate = await _getCachedExchangeRate('USD', userCurrency);
      double convertedAmount = amountInUSD * exchangeRate;
      return convertedAmount;
    } catch (e) {
      return amountInUSD; // Return the original amount in case of an error
    }
  }

  Future<String> getUserCurrencySymbol() async {
    await _currencyConfig.loadConfig();
    String? userCurrency = await _settings.getCurrency();
    userCurrency ??= 'USD';
    return _currencyConfig.getCurrencySymbol(userCurrency);
  }
}
