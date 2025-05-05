import 'package:stock_overflow/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:stock_overflow/data/models/company.dart';
import 'package:stock_overflow/utils/config/color_config.dart';
import 'package:stock_overflow/pages/watchlist_page.dart';
import 'package:stock_overflow/widgets/news_card.dart';
import 'package:stock_overflow/widgets/home_company_tile.dart';
import 'package:stock_overflow/utils/show_confirmation_dialog.dart';
import 'package:stock_overflow/data/services/local_storage_service.dart';
import 'package:stock_overflow/utils/logic/home_data.dart';
import 'package:stock_overflow/widgets/apikey_popup.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  final String title;
  final ColorConfig colorConfig;
  final List<Company> defaultCompanyList;
  final ValueNotifier<ThemeMode> themeNotifier;
  final ValueNotifier<String> currencyNotifier;

  const HomePage({
    Key? key,
    required this.title,
    required this.colorConfig,
    required this.defaultCompanyList,
    required this.themeNotifier,
    required this.currencyNotifier,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late List<Company> followingCompanies = [];
  late List<Company> displayedCompanies = [];
  TextEditingController searchController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Map<String, dynamic>> newsData = [];
  bool isLoadingNews = true;
  bool isLoadingCompanies = true;
  Map<String, Map<String, dynamic>> performanceDataCache = {};

  @override
  void initState() {
    super.initState();
    _checkApiKey();
    _initializeData();

    // Listen for currency changes
    widget.currencyNotifier.addListener(_onCurrencyChanged);
  }

  @override
  void dispose() {
    widget.currencyNotifier.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  void _onCurrencyChanged() {
    setState(() {
      // Rebuild the homepage when the currency changes
    });
    _refreshData();
  }

  Future<void> _checkApiKey() async {
    String? apiKey = await _secureStorage.read(key: 'apiKey');
    if (apiKey == null) {
      _showApiKeyPopup();
    }
  }

  void _showApiKeyPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ApiKeyPopup();
      },
    );
  }

  Future<void> _initializeData() async {
    await _localStorageService.readData('companies').then((value) {
      setState(() {
        followingCompanies = value?.map<Company>((company) => Company.fromJson(company)).toList() ?? [];
        displayedCompanies = followingCompanies;
        for (var company in followingCompanies) {
          fetchPerformanceData(company.symbol);
        }
        fetchNewsDataOnce(followingCompanies.map((company) => company.symbol).toList());
      });
      setState(() {
        isLoadingCompanies = false; // Data loading complete
      });
    });
  }

  Future<void> fetchNewsDataOnce(List<String> symbols) async {
    await HomeDataFetcher.fetchNewsDataOnce(symbols).then((data) {
      setState(() {
        newsData = data.take(10).toList(); // Limit to 10 news items
        isLoadingNews = false;
      });
    }).catchError((e) {
      setState(() {
        newsData = [];
        isLoadingNews = false;
      });
    });
  }

  Future<void> fetchPerformanceData(String symbol) async {
    try {
      final data = await HomeDataFetcher.fetchPerformanceData(symbol);
      setState(() {
        performanceDataCache[symbol] = data;
      });
    } catch (e) {
      setState(() {
        performanceDataCache[symbol] = {'error': e.toString()};
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoadingCompanies = true;
      performanceDataCache.clear(); // Clear cache to re-fetch data
    });
    await _initializeData();
  }

  void _navigateToWatchlistPage(BuildContext context) async {
    final List<Company>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WatchlistPage(
          selectedCompanies: followingCompanies,
          colorConfig: widget.colorConfig,
          defaultCompanies: widget.defaultCompanyList,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        followingCompanies = result.where((company) => company.isFollowing).toList();
        displayedCompanies = followingCompanies.isEmpty ? [] : followingCompanies;
      });

      for (var company in followingCompanies) {
        if (!performanceDataCache.containsKey(company.symbol)) {
          fetchPerformanceData(company.symbol);
        }
      }

      fetchNewsDataOnce(followingCompanies.map((company) => company.symbol).toList());
    }
  }

  void _navigateToSettingsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          themeNotifier: widget.themeNotifier,
          colorConfig: widget.colorConfig,
          currencyNotifier: widget.currencyNotifier,
        ),
      ),
    );
  }

  void _filterCompanies(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedCompanies = followingCompanies.isEmpty ? [] : followingCompanies;
      } else {
        displayedCompanies = followingCompanies
            .where((company) =>
        company.symbol.toLowerCase().contains(query.toLowerCase()) ||
            company.name.toLowerCase().contains(query.toLowerCase()) ||
            company.type.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).brightness == Brightness.dark
                  ? widget.colorConfig.getColor('dark', 'colorAccent')
                  : widget.colorConfig.getColor('light', 'colorAccent'),
            ),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 45), // Offset to move the menu down
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 28.0),
              onSelected: (String result) {
                if (result == 'Watchlist') {
                  _navigateToWatchlistPage(context);
                } else if (result == 'Settings') {
                  _navigateToSettingsPage(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Watchlist',
                  child: ListTile(
                    leading: Icon(Icons.article),
                    title: Text('Watchlist'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by symbol, name, or type...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: _filterCompanies,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Expanded(
              child: isLoadingCompanies
                  ? const Center(child: CircularProgressIndicator())
                  : followingCompanies.isEmpty
                  ? const Center(
                child: Text(
                  'No companies selected',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
                  : displayedCompanies.isEmpty
                  ? const Center(
                child: Text(
                  'No matching companies found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
                  : ListView.builder(
                itemCount: displayedCompanies.length,
                itemBuilder: (context, index) {
                  var company = displayedCompanies[index];
                  var data = performanceDataCache[company.symbol];
                  return CompanyTile(
                    company: company,
                    data: data,
                    colorConfig: widget.colorConfig,
                    currencyNotifier: widget.currencyNotifier,
                  );
                },
              ),
            ),
            if (!isKeyboardVisible)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                child: Container(
                  height: 130.0,
                  width: double.infinity,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? widget.colorConfig.getColor('dark', 'newsBackground')
                      : widget.colorConfig.getColor('light', 'newsBackground'),
                  child: isLoadingNews
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemCount: newsData.isEmpty ? 1 : newsData.length,
                        itemBuilder: (context, index) {
                          if (newsData.isEmpty) {
                            return Container(
                              width: MediaQuery.of(context).size.width - 16.0,
                              margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                              child: Card(
                                elevation: 0,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? widget.colorConfig.getColor('dark', 'card')
                                    : widget.colorConfig.getColor('light', 'card'),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                  ),
                                ),
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'News not available',
                                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return NewsCard(
                              newsData: newsData[index],
                              cardColor: widget.colorConfig.getColor(
                                  Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light', 'card'),
                              onTap: (url) => showConfirmationDialog(context, url),
                            );
                          }
                        },
                      ),
                      Positioned(
                        bottom: 8.0,
                        left: 0.0,
                        right: 0.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(newsData.isEmpty ? 0 : newsData.length, (int index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              height: 8.0,
                              width: 8.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index ? Colors.blueAccent : Colors.grey,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
