import 'package:stock_overflow/utils/APIUtils/alphavantage_api.dart';

class NewsRepository {
  final AlphaVantageAPI _api = AlphaVantageAPI();

  Future<List<Map<String, dynamic>>> fetchNewsData(List<String> symbols) async {
    var newsData = await _api.fetchLatestNews(symbols);
    if (newsData.containsKey('feed')) {
      return List<Map<String, dynamic>>.from(newsData['feed']).take(10).toList();
    }
    return [];
  }
}
