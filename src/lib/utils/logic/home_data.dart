import 'package:stock_overflow/utils/APIUtils/alphavantage_api.dart';

class HomeDataFetcher {
  static final AlphaVantageAPI api = AlphaVantageAPI();

  static Future<List<Map<String, dynamic>>> fetchNewsDataOnce(List<String> symbols) async {
    try {
      var newsDataResponse = await api.fetchLatestNews(symbols);
      if (newsDataResponse.containsKey('feed')) {
        return List<Map<String, dynamic>>.from(newsDataResponse['feed']);
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch news data: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchPerformanceData(String symbol) async {
    try {
      var data = await api.fetchSymbolInfo(symbol);
      if (data.containsKey('Information')) {
        return {'error': 'API limit reached'};
      }
      if (data.containsKey('Global Quote')) {
        return {
          'value': double.tryParse(data['Global Quote']['05. price']) ?? 0.0,
          'change': double.tryParse(data['Global Quote']['10. change percent'].replaceAll('%', '')) ?? 0.0,
        };
      } else {
        return {'error': 'No quote data available'};
      }
    } catch (e) {
      throw Exception('Failed to fetch performance data: $e');
    }
  }
}
