import 'package:flutter/material.dart';
import 'package:stock_overflow/data/models/company.dart';
import 'package:stock_overflow/utils/config/color_config.dart';
import 'package:stock_overflow/utils/logic/currency_converter.dart';
import 'package:stock_overflow/utils/APIUtils/alphavantage_api.dart';
import 'package:stock_overflow/widgets/line_chart.dart';
import 'package:stock_overflow/widgets/time_button.dart';
import 'package:stock_overflow/widgets/compact_company_tile.dart';
import 'package:stock_overflow/utils/logic/compare_data.dart';
import 'package:stock_overflow/utils/logic/home_data.dart';

import '../widgets/dropdown_item.dart';

class ComparePage extends StatefulWidget {
  final String initialSymbol;
  final String initialName;
  final ColorConfig colorConfig;
  final ValueNotifier<String> currencyNotifier;

  const ComparePage({
    Key? key,
    required this.initialSymbol,
    required this.initialName,
    required this.colorConfig,
    required this.currencyNotifier,
  }) : super(key: key);

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  late String selectedSymbol;
  late List<String> selectedSymbols;
  late List<Company> allCompanies;
  late List<Color> colors;
  final AlphaVantageAPI _api = AlphaVantageAPI();
  late CurrencyConverter _currencyConverter;
  String selectedTimeUnit = '1W';
  Map<String, dynamic> historicalDataCache = {};
  Map<String, Map<String, dynamic>> performanceDataCache = {};
  String currencySymbol = '';
  double exchangeRate = 1.0;
  bool isLoadingCompanies = true;

  @override
  void initState() {
    super.initState();
    selectedSymbol = widget.initialSymbol;
    selectedSymbols = [selectedSymbol];
    colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];
    _currencyConverter = CurrencyConverter();
    _loadCurrencyData();
    _fetchCompaniesAndData();
    widget.currencyNotifier.addListener(_onCurrencyChanged);
  }

  @override
  void dispose() {
    widget.currencyNotifier.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  Future<void> _loadCurrencyData() async {
    currencySymbol = await _currencyConverter.getUserCurrencySymbol();
    setState(() {});
  }

  void _onCurrencyChanged() {
    _loadCurrencyData();
  }

  Future<void> _fetchCompaniesAndData() async {
    allCompanies = await CompareDataFetcher.fetchSelectedCompanies();
    setState(() {
      isLoadingCompanies = false;
    });
    await _fetchHistoricalData(selectedSymbols, clearCache: false);
  }

  Future<void> _fetchHistoricalData(List<String> symbols,
      {bool clearCache = false}) async {
    if (clearCache) {
      historicalDataCache.clear();
      performanceDataCache.clear();
    }
    for (var symbol in symbols) {
      if (!historicalDataCache.containsKey(symbol)) {
        try {
          var data = await _api.fetchHistoricalData(symbol, selectedTimeUnit);
          historicalDataCache[symbol] = parseTimeSeriesData(data);
          var performanceData =
              await HomeDataFetcher.fetchPerformanceData(symbol);
          performanceDataCache[symbol] = performanceData;
        } catch (e) {
          _showSnackBar('Data for $symbol could not be loaded');
        }
      }
    }
    setState(() {});
  }

  Map<String, dynamic> parseTimeSeriesData(Map<String, dynamic> data) {
    final timeSeriesKey =
        data.keys.firstWhere((key) => key.startsWith('Time Series'));
    final timeSeriesData = data[timeSeriesKey] as Map<String, dynamic>;
    return timeSeriesData;
  }

  bool _toggleComparison(String symbol) {
    if (selectedSymbols.contains(symbol)) {
      setState(() {
        selectedSymbols.remove(symbol);
        historicalDataCache.remove(symbol);
        performanceDataCache.remove(symbol);
      });
      return true;
    } else if (selectedSymbols.length < 4) {
      setState(() {
        selectedSymbols.add(symbol);
        _fetchHistoricalData([symbol], clearCache: false);
      });
      return true;
    } else {
      _showSnackBar('You can only compare up to 4 stocks.');
      return false;
    }
  }

  void _showSnackBar(String message) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color snackBarBackgroundColor =
        isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    Color snackBarTextColor = isDarkMode ? Colors.white : Colors.black;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: snackBarTextColor),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: snackBarBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String themeMode = isDarkMode ? 'dark' : 'light';
    Color appBarBackground =
        widget.colorConfig.getColor(themeMode, 'appBarBackground');
    Color appBarText = widget.colorConfig.getColor(themeMode, 'appBarText');
    Color backgroundColor =
        widget.colorConfig.getColor(themeMode, 'newsBackground');
    Color cardColor = widget.colorConfig.getColor(themeMode, 'card');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Stocks',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBackground,
      ),
      body: isLoadingCompanies
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCompaniesAndData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      width: double.infinity,
                      child: DropdownButton<String>(
                        value: selectedSymbol,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedSymbol = newValue;
                              if (!selectedSymbols.contains(selectedSymbol)) {
                                if (_toggleComparison(selectedSymbol)) {
                                  _fetchHistoricalData([selectedSymbol],
                                      clearCache: false);
                                }
                              }
                            });
                          }
                        },
                        items: allCompanies
                            .map<DropdownMenuItem<String>>((Company company) {
                          return DropdownMenuItem<String>(
                            value: company.symbol,
                            child: DropdownItem(
                              company: company,
                              isSelected:
                                  selectedSymbols.contains(company.symbol),
                              toggleComparison: _toggleComparison,
                            ),
                          );
                        }).toList(),
                        isExpanded: true,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TimeUnitsRow(
                            onPressed: (String timeUnit) {
                              setState(() {
                                selectedTimeUnit = timeUnit;
                                _fetchHistoricalData(selectedSymbols,
                                    clearCache: true);
                              });
                            },
                            colorConfig: widget.colorConfig,
                            selectedTimeUnit: selectedTimeUnit,
                          ),
                          Container(
                            height: 300,
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: historicalDataCache.isEmpty
                                ? Center(
                                    child: _buildEmptyState(appBarBackground,
                                        appBarText, cardColor, Colors.green))
                                : Center(
                                    child: LineChart(
                                      data: selectedSymbols.map((symbol) {
                                        var symbolData =
                                            historicalDataCache[symbol];
                                        if (symbolData == null) {
                                          return {
                                            'symbol': symbol,
                                            'color': colors[selectedSymbols
                                                .indexOf(symbol)],
                                            'data': []
                                          };
                                        }
                                        return {
                                          'symbol': symbol,
                                          'color': colors[
                                              selectedSymbols.indexOf(symbol)],
                                          'data':
                                              symbolData.entries.map((entry) {
                                            return {
                                              'time': entry.key,
                                              'value': double.parse(
                                                      entry.value['4. close']) *
                                                  exchangeRate,
                                            };
                                          }).toList(),
                                        };
                                      }).toList(),
                                      colorConfig: widget.colorConfig,
                                      selectedTimeUnit: selectedTimeUnit,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: selectedSymbols.isEmpty
                          ? Center(
                              child: Text(
                                'No stocks selected',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: appBarText,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: selectedSymbols.length,
                              itemBuilder: (context, index) {
                                var symbol = selectedSymbols[index];
                                var company = allCompanies
                                    .firstWhere((c) => c.symbol == symbol);
                                var symbolData = performanceDataCache[symbol];
                                return CompactStockTile(
                                  company: company,
                                  data: symbolData ?? {},
                                  colorConfig: widget.colorConfig,
                                  currencyNotifier: widget.currencyNotifier,
                                  tileColor: colors[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(Color newsBackground, Color textColor,
      Color cardColor, Color positiveChange) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: cardColor,
      ),
      child: const Center(
        child: Text('Graph not available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
