import 'package:flutter/material.dart';
import 'package:stock_overflow/pages/home_page.dart';
import 'package:stock_overflow/utils/config/color_config.dart';
import 'package:stock_overflow/utils/config/default_company_config.dart';
import 'package:stock_overflow/utils/logic/settings_data.dart';
import 'package:stock_overflow/data/models/company.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final colorConfig = ColorConfig();
  await colorConfig.loadConfig();

  final defaultCompanyConfig = DefaultCompanyConfig();
  await defaultCompanyConfig.loadConfig();

  final settingsData = SettingsData();
  bool? isDarkMode = await settingsData.getDarkMode();
  String? initialCurrency = await settingsData.getCurrency();
  ThemeMode initialThemeMode = isDarkMode != null && isDarkMode ? ThemeMode.dark : ThemeMode.light;
  String initialCurrencySetting = initialCurrency ?? 'USD';

  runApp(MyApp(
    colorConfig: colorConfig,
    defaultCompanyList: defaultCompanyConfig.companies,
    initialThemeMode: initialThemeMode,
    initialCurrency: initialCurrencySetting,
  ));
}

class MyApp extends StatelessWidget {
  final ColorConfig colorConfig;
  final List<Company> defaultCompanyList;
  final ThemeMode initialThemeMode;
  final String initialCurrency;

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
  static final ValueNotifier<String> currencyNotifier = ValueNotifier('USD');

  MyApp({
    Key? key,
    required this.colorConfig,
    required this.defaultCompanyList,
    required this.initialThemeMode,
    required this.initialCurrency,
  }) : super(key: key) {
    themeNotifier.value = initialThemeMode;
    currencyNotifier.value = initialCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Stock Overflow',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: colorConfig.getColor('light', 'background'),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, secondary: Colors.white),
            cardColor: colorConfig.getColor('light', 'card'),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: colorConfig.getColor('light', 'text')),
              bodyMedium: TextStyle(color: colorConfig.getColor('light', 'text')),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            scaffoldBackgroundColor: colorConfig.getColor('dark', 'background'),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, secondary: Colors.black, brightness: Brightness.dark),
            cardColor: colorConfig.getColor('dark', 'card'),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: colorConfig.getColor('dark', 'text')),
              bodyMedium: TextStyle(color: colorConfig.getColor('dark', 'text')),
            ),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: HomePage(
            title: 'Stock Overflow',
            colorConfig: colorConfig,
            defaultCompanyList: defaultCompanyList,
            themeNotifier: themeNotifier,
            currencyNotifier: currencyNotifier,
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
