import 'dart:ui';

class LineChartData {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final Color color;

  LineChartData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.color,
  });

  factory LineChartData.fromJson(Map<String, dynamic> json) {
    final globalQuote = json['Global Quote'];
    return LineChartData(
      symbol: globalQuote['01. symbol'],
      price: double.parse(globalQuote['05. price']),
      change: double.parse(globalQuote['09. change']),
      changePercent: double.parse(globalQuote['10. change percent'].replaceAll('%', '')),
      color: json['color'],
    );
  }
}
