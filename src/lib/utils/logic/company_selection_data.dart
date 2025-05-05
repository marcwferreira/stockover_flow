import 'package:stock_overflow/data/models/company.dart';
import 'package:stock_overflow/utils/APIUtils/alphavantage_api.dart';

class CompanySelectionDataFetcher {
  static Future<SearchResponse> searchSymbols(AlphaVantageAPI api, String searchString, List<Company> selectedCompanies) async {
    try {
      var response = await api.searchSymbols(searchString);
      List<Company> companies = [];
      String? errorMessage;
      if (response.containsKey('bestMatches')) {
        for (var item in response['bestMatches']) {
          String symbol = item['1. symbol'];
          String name = item['2. name'];
          String type = item['3. type'];
          double matchScore = double.parse(item['9. matchScore']);

          // Check if the company is already in the selected list
          bool isFollowing = selectedCompanies.any((c) => c.symbol == symbol);

          companies.add(Company(
            id: companies.length + 1,
            symbol: symbol,
            name: name,
            type: type,
            value: matchScore,
            isFollowing: isFollowing,
          ));
        }
      } else if (response.containsKey('Information')) {
        errorMessage = 'API limit reached. Please try again later.';
      } else {
        errorMessage = 'No results found.';
      }
      return SearchResponse(companies: companies, errorMessage: errorMessage);
    } catch (e) {
      return SearchResponse(companies: [], errorMessage: 'Error during search.\nPlease try again later.');
    }
  }
}

class SearchResponse {
  final List<Company> companies;
  final String? errorMessage;

  SearchResponse({required this.companies, this.errorMessage});
}
