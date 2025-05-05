import 'package:localstorage/localstorage.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  late LocalStorage _localStorage;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal() {
    _init();
  }

  Future<void> _init() async {
    _localStorage = LocalStorage('stock_overflow');
    await _localStorage.ready;
  }

  LocalStorage get localStorage => _localStorage;

  Future<void> writeData(String key, dynamic data) async {
    await _localStorage.ready;

    try {
      // Ensure _localStorage is initialized
      await _localStorage.setItem(key, data);
    } catch (e) {
      return;
      //print("Error writing data: $e");
    }
  }

  Future<dynamic> readData(String key) async {
    await _localStorage.ready;
    try {
      final dynamic rawData = await _localStorage.getItem(key);

      if (rawData == null) {
        return;
        //print("Data is null");
      }

      return rawData;
    } catch (e) {
      //print("Error reading data: $e");
      return null;
    }
  }

}
