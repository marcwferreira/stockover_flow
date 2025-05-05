class PerformanceData {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;

  PerformanceData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    final globalQuote = json['Global Quote'];
    return PerformanceData(
      symbol: globalQuote['01. symbol'],
      price: double.parse(globalQuote['05. price']),
      change: double.parse(globalQuote['09. change']),
      changePercent: double.parse(globalQuote['10. change percent'].replaceAll('%', '')),
    );
  }
}
