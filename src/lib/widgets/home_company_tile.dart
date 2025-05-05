import 'package:flutter/material.dart';
import 'package:stock_overflow/data/models/company.dart';
import 'package:stock_overflow/pages/symbol_page.dart';
import 'package:stock_overflow/utils/config/color_config.dart';
import 'package:stock_overflow/utils/logic/currency_converter.dart';

class CompanyTile extends StatefulWidget {
  final Company company;
  final Map<String, dynamic>? data;
  final ColorConfig colorConfig;
  final ValueNotifier<String> currencyNotifier;

  const CompanyTile({
    Key? key,
    required this.company,
    this.data,
    required this.colorConfig,
    required this.currencyNotifier,
  }) : super(key: key);

  @override
  State<CompanyTile> createState() => _CompanyTileState();
}

class _CompanyTileState extends State<CompanyTile> {
  late double value;
  late double convertedValue;
  late double change;
  late Color changeColor;
  String currencySymbol = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    loadCurrencyData();

    // Listen for currency changes
    widget.currencyNotifier.addListener(_onCurrencyChanged);
  }

  @override
  void didUpdateWidget(CompanyTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _initializeValues();
      loadCurrencyData();
    }
  }

  void _initializeValues() {
    value = widget.data?['value'] ?? 0.0;
    convertedValue = widget.data?['value'] ?? 0.0;
    change = widget.data?['change'] ?? 0.0;
    changeColor = change >= 0 ? Colors.green : Colors.red;
  }

  @override
  void dispose() {
    widget.currencyNotifier.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  Future<void> loadCurrencyData() async {
    if (widget.data == null || widget.data!.containsKey('error')) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    CurrencyConverter converter = CurrencyConverter();
    double convertedResult = await converter.convertToUserCurrency(value);
    String symbol = await converter.getUserCurrencySymbol();
    setState(() {
      convertedValue = convertedResult;
      currencySymbol = symbol;
      isLoading = false;
    });
  }

  void _onCurrencyChanged() {
    setState(() {
      isLoading = true;
    });
    loadCurrencyData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const ListTile(
          title: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SymbolPage(
                symbol: widget.company.symbol,
                name: widget.company.name,
                colorConfig: widget.colorConfig,
                currencyNotifier: widget.currencyNotifier,
              ),
            ),
          );
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.company.symbol,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.company.name),
          ],
        ),
        subtitle: Text(widget.company.type),
        trailing: widget.data == null
            ? const CircularProgressIndicator()
            : widget.data!.containsKey('error')
            ? const Icon(Icons.error)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$currencySymbol${convertedValue.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              '${change.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: changeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
