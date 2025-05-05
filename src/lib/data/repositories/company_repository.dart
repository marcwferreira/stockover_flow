import 'package:stock_overflow/data/services/local_storage_service.dart';
import 'package:stock_overflow/utils/APIUtils/alphavantage_api.dart';
import 'package:stock_overflow/data/models/company.dart';
import 'package:stock_overflow/data/models/performance_data.dart';

class CompanyRepository {
  final LocalStorageService _localStorageService = LocalStorageService();
  final AlphaVantageAPI _api = AlphaVantageAPI();

  Future<List<Company>> fetchSavedCompanies() async {
    var data = await _localStorageService.readData('companies');
    if (data != null) {
      return data.map<Company>((company) => Company.fromJson(company)).toList();
    }
    return [];
  }

  Future<void> saveCompanies(List<Company> companies) async {
    await _localStorageService.writeData('companies', companies.map((c) => c.toJson()).toList());
  }

  Future<PerformanceData> fetchPerformanceData(String symbol) async {
    var response = await _api.fetchSymbolInfo(symbol);
    return PerformanceData.fromJson(response);
  }
}
