import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stock_overflow/data/services/secure_storage_service.dart';

class AlphaVantageAPI {
  String apiKey = 'default';
  String currency;

  //static String baseUrl = 'https://www.alphavantage.co/query';
  static String baseUrl = 'http://10.0.2.2:5000/query';

  AlphaVantageAPI({this.currency = "USD"}) {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    String? key = await SecureStorageService().readSecureData('apiKey');
    if (key != null) {
      apiKey = key;
    } else {
      return;
      //print('API key not found.');
    }
  }

  Future<Map<String, dynamic>> searchSymbols(String searchString) async {
    await _loadApiKey(); // Ensure API key is loaded
    var url = '$baseUrl?function=SYMBOL_SEARCH&keywords=$searchString&apikey=$apiKey';
    var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load symbols with status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchSymbolInfo(String symbol) async {
    await _loadApiKey(); // Ensure API key is loaded
    var url = '$baseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey';
    var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load symbol information with status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchSymbolNews(String symbol) async {
    await _loadApiKey(); // Ensure API key is loaded
    var url = '$baseUrl?function=NEWS_SENTIMENT&limit=10&tickers=$symbol&apikey=$apiKey';
    var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load news with status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchLatestNews(List<String> symbols) async {
    await _loadApiKey(); // Ensure API key is loaded
    var symbolString = symbols.join(',');
    var url = '$baseUrl?function=NEWS_SENTIMENT&limit=10&tickers=$symbolString&apikey=$apiKey';
    var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load news with status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchHistoricalData(String symbol, String interval) async {
    await _loadApiKey(); // Ensure API key is loaded
    String function;
    String adjustedInterval;
    String outputSize = 'compact'; // Default output size

    switch (interval) {
      case '1min':
      case '5min':
      case '15min':
      case '30min':
      case '60min':
        function = 'TIME_SERIES_INTRADAY';
        adjustedInterval = interval;
        break;
      case '1h':
        function = 'TIME_SERIES_INTRADAY';
        adjustedInterval = '60min';
        break;
      case '1D':
        function = 'TIME_SERIES_INTRADAY';
        adjustedInterval = '1min'; // Fetch 24 hours data in 1-min intervals
        outputSize = 'full'; // Full data for the day
        break;
      case '1W':
        function = 'TIME_SERIES_DAILY';
        adjustedInterval = 'daily';
        outputSize = '7'; // Fetch data for 7 days
        break;
      case '1M':
        function = 'TIME_SERIES_DAILY';
        adjustedInterval = 'daily';
        outputSize = '30'; // Fetch data for 30 days
        break;
      case '1Y':
        function = 'TIME_SERIES_WEEKLY';
        adjustedInterval = 'weekly';
        outputSize = '52'; // Fetch data for 52 weeks
        break;
      default:
        throw Exception('Invalid interval: $interval');
    }

    String url;
    if (function == 'TIME_SERIES_INTRADAY') {
      url = '$baseUrl?function=$function&symbol=$symbol&interval=$adjustedInterval&outputsize=$outputSize&apikey=$apiKey';
    } else if (function == 'TIME_SERIES_DAILY' && (interval == '1W' || interval == '1M')) {
      url = '$baseUrl?function=$function&symbol=$symbol&outputsize=$outputSize&apikey=$apiKey';
    } else if (function == 'TIME_SERIES_WEEKLY' && interval == '1Y') {
      url = '$baseUrl?function=$function&symbol=$symbol&apikey=$apiKey';
    } else {
      url = '$baseUrl?function=$function&symbol=$symbol&apikey=$apiKey';
    }

    var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load historical data with status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchCurrencyExchangeRate(String fromCurrency, String toCurrency) async {
    await _loadApiKey(); // Ensure API key is loaded
    var url = '$baseUrl?function=CURRENCY_EXCHANGE_RATE&from_currency=$fromCurrency&to_currency=$toCurrency&apikey=$apiKey';
    var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load currency exchange rate with status code: ${response.statusCode}');
    }
  }
}
