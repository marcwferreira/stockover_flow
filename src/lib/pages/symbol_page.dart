import 'package:flutter/material.dart';
import 'package:stock_overflow/utils/config/color_config.dart';
import 'package:stock_overflow/utils/APIUtils/alphavantage_api.dart';
import 'package:stock_overflow/widgets/performance_chart.dart';
import 'package:stock_overflow/widgets/time_button.dart';
import '../widgets/news_card.dart';
import '../utils/show_confirmation_dialog.dart';
import 'package:stock_overflow/utils/logic/currency_converter.dart';
import 'package:stock_overflow/pages/compare_page.dart';

class SymbolPage extends StatefulWidget {
  final String name;
  final String symbol;
  final ColorConfig colorConfig;
  final ValueNotifier<String> currencyNotifier;

  const SymbolPage({
    Key? key,
    required this.name,
    required this.symbol,
    required this.colorConfig,
    required this.currencyNotifier,
  }) : super(key: key);

  @override
  State<SymbolPage> createState() => _SymbolPageState();
}

class _SymbolPageState extends State<SymbolPage> {
  late AlphaVantageAPI _api;
  late Future<Map<String, dynamic>> _symbolInfoFuture;
  late Future<Map<String, dynamic>> _symbolNewsFuture;
  late Future<Map<String, dynamic>> _historicalDataFuture;
  late CurrencyConverter _currencyConverter;
  String selectedTimeUnit = '1W';
  String currencySymbol = '';
  double exchangeRate = 1.0;

  @override
  void initState() {
    super.initState();
    _api = AlphaVantageAPI();
    _currencyConverter = CurrencyConverter();
    _loadData();
    _loadCurrencyData();
    widget.currencyNotifier.addListener(_onCurrencyChanged);
  }

  @override
  void dispose() {
    widget.currencyNotifier.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  void _loadData() {
    _symbolInfoFuture = _api.fetchSymbolInfo(widget.symbol);
    _symbolNewsFuture = _api.fetchSymbolNews(widget.symbol);
    _historicalDataFuture = _api.fetchHistoricalData(widget.symbol, selectedTimeUnit);
  }

  Future<void> _loadCurrencyData() async {
    currencySymbol = await _currencyConverter.getUserCurrencySymbol();
    setState(() {});
  }

  void _onCurrencyChanged() {
    _loadCurrencyData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
      _loadCurrencyData();
    });
  }

  Map<String, dynamic> parseTimeSeriesData(Map<String, dynamic> data) {
    final timeSeriesKey = data.keys.firstWhere((key) => key.startsWith('Time Series'), orElse: () => '');
    if (timeSeriesKey.isEmpty) return {};
    final timeSeriesData = data[timeSeriesKey] as Map<String, dynamic>;
    return timeSeriesData;
  }

  Future<double> _convertCurrency(double amountInUSD) async {
    return await _currencyConverter.convertToUserCurrency(amountInUSD);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String themeMode = isDarkMode ? 'dark' : 'light';
    Color appBarBackground = widget.colorConfig.getColor(themeMode, 'appBarBackground');
    Color appBarText = widget.colorConfig.getColor(themeMode, 'appBarText');
    Color newsBackground = widget.colorConfig.getColor(themeMode, 'newsBackground');
    Color positiveChange = widget.colorConfig.getColor(themeMode, 'positiveChange');
    Color negativeChange = widget.colorConfig.getColor(themeMode, 'negativeChange');
    Color cardColor = widget.colorConfig.getColor(themeMode, 'card');
    Color textColor = widget.colorConfig.getColor(themeMode, 'text');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.symbol,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: appBarText),
                ),
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 18, color: appBarText, overflow: TextOverflow.ellipsis),
                  maxLines: 1,
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.compare_arrows, color: appBarText),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComparePage(
                      initialSymbol: widget.symbol,
                      initialName: widget.name,
                      colorConfig: widget.colorConfig,
                      currencyNotifier: widget.currencyNotifier,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: appBarBackground,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: _symbolInfoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || snapshot.data == null) {
                    return _buildEmptyState(newsBackground, textColor, cardColor, positiveChange);
                  }

                  var symbolData = snapshot.data!;
                  if (!symbolData.containsKey('Global Quote')) {
                    return _buildEmptyState(newsBackground, textColor, cardColor, positiveChange);
                  }

                  double usdCurrentValue = double.parse(symbolData['Global Quote']['05. price']);
                  double usdChangeValue = double.parse(symbolData['Global Quote']['09. change']);
                  double usdChangePercent = double.parse(symbolData['Global Quote']['10. change percent'].replaceAll('%', ''));

                  return FutureBuilder<double>(
                    future: _convertCurrency(usdCurrentValue),
                    builder: (context, currencySnapshot) {
                      double currentValue = currencySnapshot.data ?? usdCurrentValue;
                      return FutureBuilder<double>(
                        future: _convertCurrency(usdChangeValue),
                        builder: (context, changeSnapshot) {
                          double changeValue = changeSnapshot.data ?? usdChangeValue;
                          double changePercent = usdChangePercent;
                          Color valueColor = changeValue >= 0 ? positiveChange : negativeChange;

                          return Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: newsBackground,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$currencySymbol${currentValue.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                                ),
                                Text(
                                  '${changeValue >= 0 ? '+' : ''}${changeValue.toStringAsFixed(2)} (${changePercent >= 0 ? '+' : ''}$changePercent%)',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
                                ),
                                TimeUnitsRow(
                                  onPressed: (String timeUnit) {
                                    setState(() {
                                      selectedTimeUnit = timeUnit;
                                      _historicalDataFuture = _api.fetchHistoricalData(widget.symbol, timeUnit);
                                    });
                                  },
                                  colorConfig: widget.colorConfig,
                                  selectedTimeUnit: selectedTimeUnit,
                                ),
                                FutureBuilder<Map<String, dynamic>>(
                                  future: _historicalDataFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        padding: const EdgeInsets.all(5),
                                        margin: const EdgeInsets.only(top: 10),
                                        width: double.infinity,
                                        height: 250,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                      return Container(
                                        padding: const EdgeInsets.all(5),
                                        margin: const EdgeInsets.only(top: 10),
                                        width: double.infinity,
                                        height: 250,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16.0),
                                          child: Container(
                                            color: cardColor,
                                            child: const Center(
                                              child: Text('No data available'),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    var timeSeriesData = parseTimeSeriesData(snapshot.data!);
                                    if (timeSeriesData.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(5),
                                        margin: const EdgeInsets.only(top: 10),
                                        width: double.infinity,
                                        height: 250,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16.0),
                                          child: Container(
                                            color: cardColor,
                                            child: const Center(
                                              child: Text('No data available'),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    var data = timeSeriesData.entries.map((entry) {
                                      return {
                                        'time': entry.key,
                                        'open': double.parse(entry.value['1. open']) * exchangeRate,
                                        'high': double.parse(entry.value['2. high']) * exchangeRate,
                                        'low': double.parse(entry.value['3. low']) * exchangeRate,
                                        'close': double.parse(entry.value['4. close']) * exchangeRate,
                                      };
                                    }).toList();

                                    return PerformanceChart(
                                      data: data,
                                      selectedTimeUnit: selectedTimeUnit,
                                      colorConfig: widget.colorConfig,
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: newsBackground,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent News',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _symbolNewsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load news. Please try again later.',
                              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!['feed'] == null) {
                          return Center(
                            child: Text(
                              'No news available',
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }

                        var newsData = snapshot.data!['feed'] as List;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: newsData.length,
                          itemBuilder: (BuildContext context, int index) {
                            var article = newsData[index];
                            return NewsCard(
                              newsData: article,
                              cardColor: cardColor,
                              onTap: (url) => showConfirmationDialog(context, url),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color newsBackground, Color textColor, Color cardColor, Color positiveChange) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: newsBackground,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$currencySymbol${0.0.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          Text(
            '${'+0.0'} (${'+0.0%'})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: positiveChange),
          ),
          TimeUnitsRow(
            onPressed: (String timeUnit) {
              setState(() {
                selectedTimeUnit = timeUnit;
                _historicalDataFuture = _api.fetchHistoricalData(widget.symbol, timeUnit);
              });
            },
            colorConfig: widget.colorConfig,
            selectedTimeUnit: selectedTimeUnit,
          ),
          Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(top: 10),
            width: double.infinity,
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                color: cardColor,
                child: const Center(
                  child: Text('Graph not available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
