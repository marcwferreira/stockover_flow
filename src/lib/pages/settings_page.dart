import 'package:flutter/material.dart';
import 'package:stock_overflow/utils/logic/settings_data.dart';
import 'package:stock_overflow/utils/config/color_config.dart';

class SettingsPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final ColorConfig colorConfig;
  final ValueNotifier<String> currencyNotifier;

  const SettingsPage({Key? key, required this.themeNotifier, required this.colorConfig, required this.currencyNotifier}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  final SettingsData _settingsData = SettingsData();
  final TextEditingController _apiKeyController = TextEditingController();
  String _currency = 'USD';
  bool _isDarkMode = false;
  bool _isApiKeyVisible = false;
  List<String> _currencyList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    await _settingsData.loadCurrencyConfig();
    String? currency = await _settingsData.getCurrency();
    bool? isDarkMode = await _settingsData.getDarkMode();
    String? apiKey = await _settingsData.getApiKey();

    setState(() {
      _currency = currency ?? 'USD';
      _isDarkMode = isDarkMode ?? (widget.themeNotifier.value == ThemeMode.dark);
      _currencyList = _settingsData.currencyList;
      _apiKeyController.text = apiKey ?? '';
    });
  }

  void _saveSettings() {
    _settingsData.setCurrency(_currency);
    _settingsData.setDarkMode(_isDarkMode);
    _settingsData.setApiKey(_apiKeyController.text);
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      widget.themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
      _saveSettings();
    });
  }

  void _changeCurrency(String? value) {
    setState(() {
      _currency = value!;
      widget.currencyNotifier.value = value; // Notify listeners of the currency change
      _saveSettings();
    });
  }

  void _toggleApiKeyVisibility(bool value) {
    setState(() {
      _isApiKeyVisible = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? widget.colorConfig.getColor('dark', 'card')
                  : widget.colorConfig.getColor('light', 'card'),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Preferred currency'),
                  trailing: DropdownButton<String>(
                    value: _currency,
                    onChanged: _changeCurrency,
                    items: _currencyList.map<DropdownMenuItem<String>>((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? widget.colorConfig.getColor('dark', 'card')
                  : widget.colorConfig.getColor('light', 'card'),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('API Key'),
                      Switch(
                        value: _isApiKeyVisible,
                        onChanged: _toggleApiKeyVisibility,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _apiKeyController,
                    obscureText: !_isApiKeyVisible,
                    onChanged: (value) => _settingsData.setApiKey(value),
                    decoration: const InputDecoration(
                      labelText: 'Enter API Key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(), // This will push the footer to the bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '© 2024 Stocks Overflow. All rights reserved.',
              style: TextStyle(
                fontSize: 12.0,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
