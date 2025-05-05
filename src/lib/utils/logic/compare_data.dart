import 'package:stock_overflow/data/models/company.dart';
import 'package:stock_overflow/data/services/local_storage_service.dart';

class CompareDataFetcher {
  static Future<List<Company>> fetchSelectedCompanies() async {
    final LocalStorageService localStorageService = LocalStorageService();
    List<Company> selectedCompanies = [];

    try {
      var data = await localStorageService.readData('companies');
      if (data != null) {
        selectedCompanies = data.map<Company>((company) => Company.fromJson(company)).toList();
      }
    } catch (e) {
      // Handle error or log it
    }

    return selectedCompanies;
  }
}
