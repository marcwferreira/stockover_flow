import 'package:flutter/material.dart';
import 'package:stock_overflow/data/services/local_storage_service.dart';
import 'package:stock_overflow/data/models/company.dart';
import 'package:stock_overflow/utils/APIUtils/alphavantage_api.dart';
import 'package:stock_overflow/utils/config/color_config.dart';
import 'package:stock_overflow/utils/logic/company_selection_data.dart';
import 'package:stock_overflow/widgets/watchlist_widgets.dart';

class WatchlistPage extends StatefulWidget {
  final List<Company> defaultCompanies;
  final List<Company> selectedCompanies;
  final ColorConfig colorConfig;

  const WatchlistPage({
    Key? key,
    required this.defaultCompanies,
    required this.selectedCompanies,
    required this.colorConfig,
  }) : super(key: key);

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  late List<Company> companies;
  late List<Company> selectedCompanies;
  TextEditingController searchController = TextEditingController();
  final AlphaVantageAPI api = AlphaVantageAPI();
  String? errorMessage;
  bool isReorderMode = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    selectedCompanies = List.from(widget.selectedCompanies);
    companies = List.from(widget.defaultCompanies);

    // Sync selected status in the main list
    for (var selectedCompany in selectedCompanies) {
      final index = companies.indexWhere((company) => company.id == selectedCompany.id);
      if (index != -1) {
        companies[index] = selectedCompany;
      }
    }

    if (selectedCompanies.isEmpty) {
      setState(() {
        isReorderMode = false;
      });
    }
  }

  void handleSearch() async {
    String value = searchController.text;
    setState(() {
      isSearching = true; // Start the search
    });
    if (value.isEmpty) {
      setState(() {
        companies = List.from(widget.defaultCompanies);
        // Sync selected status in the main list
        for (var selectedCompany in selectedCompanies) {
          final index = companies.indexWhere((company) => company.id == selectedCompany.id);
          if (index != -1) {
            companies[index] = selectedCompany;
          }
        }
        errorMessage = null;
        isSearching = false; // End the search
      });
      return;
    }
    try {
      var response = await CompanySelectionDataFetcher.searchSymbols(api, value, selectedCompanies);
      setState(() {
        companies = response.companies;
        errorMessage = response.errorMessage ?? (companies.isEmpty ? 'No results found' : null);
        isSearching = false; // End the search
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error during search: $e';
        isSearching = false; // End the search
      });
    }
  }

  void clearSearch() {
    searchController.clear();
    setState(() {
      companies = List.from(widget.defaultCompanies);
      // Sync selected status in the main list
      for (var selectedCompany in selectedCompanies) {
        final index = companies.indexWhere((company) => company.id == selectedCompany.id);
        if (index != -1) {
          companies[index] = selectedCompany;
        }
      }
      errorMessage = null;
      isSearching = false; // End the search
    });
  }

  void toggleReorderMode() {
    setState(() {
      isReorderMode = !isReorderMode;
    });
  }

  void _handleAccept(int data, int index) {
    setState(() {
      if (index > data) {
        index--;
      }
      final company = selectedCompanies.removeAt(data);
      selectedCompanies.insert(index, company);

      companies.removeAt(data);
      companies.insert(index, company);
    });
  }

  void _onCheckboxChanged(bool? value, Company company) {
    setState(() {
      company.isFollowing = value ?? false;
      if (value == true) {
        if (!selectedCompanies.any((c) => c.symbol == company.symbol)) {
          selectedCompanies.add(company);
        }
      } else {
        selectedCompanies.removeWhere((c) => c.symbol == company.symbol);
      }

      // Sync selected status in the main list
      final index = companies.indexWhere((c) => c.symbol == company.symbol);
      if (index != -1) {
        companies[index].isFollowing = value ?? false;
      }
    });
  }

  void _saveSelectedCompanies() {
    // Update the default companies list with the current selections
    for (var company in companies) {
      final index = widget.defaultCompanies.indexWhere((c) => c.symbol == company.symbol);
      if (index != -1) {
        widget.defaultCompanies[index] = company;
      }
    }
    LocalStorageService().writeData('companies', selectedCompanies.map((e) => e.toJson()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Companies', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _saveSelectedCompanies();
              Navigator.pop(context, selectedCompanies);
            },
          ),
          IconButton(
            icon: Icon(isReorderMode ? Icons.search : Icons.reorder),
            onPressed: toggleReorderMode,
          ),
        ],
        bottom: isReorderMode
            ? null
            : PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearSearch,
                ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by symbol...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? widget.colorConfig.getColor('dark', 'card')
                          : widget.colorConfig.getColor('light', 'card'),
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? widget.colorConfig.getColor('dark', 'text')
                            : widget.colorConfig.getColor('light', 'text'),
                      ),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? widget.colorConfig.getColor('dark', 'text')
                          : widget.colorConfig.getColor('light', 'text'),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: handleSearch,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? widget.colorConfig.getColor('dark', 'background')
            : widget.colorConfig.getColor('light', 'background'),
        child: isSearching
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Text(
            errorMessage!,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? widget.colorConfig.getColor('dark', 'text')
                  : widget.colorConfig.getColor('light', 'text'),
            ),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: isReorderMode
              ? selectedCompanies.isEmpty
              ? Center(
            child: Text(
              'No companies selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? widget.colorConfig.getColor('dark', 'text')
                    : widget.colorConfig.getColor('light', 'text'),
              ),
            ),
          )
              : ListView.builder(
            itemCount: selectedCompanies.length + 1,
            itemBuilder: (context, index) {
              return buildDraggableListItem(
                context,
                index,
                false,
                selectedCompanies,
                _handleAccept,
                widget.colorConfig,
              );
            },
          )
              : companies.isEmpty
              ? Center(
            child: Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? widget.colorConfig.getColor('dark', 'text')
                    : widget.colorConfig.getColor('light', 'text'),
              ),
            ),
          )
              : ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              return buildCompanyCheckboxListTile(
                context,
                companies[index],
                selectedCompanies,
                widget.colorConfig,
                _onCheckboxChanged,
              );
            },
          ),
        ),
      ),
    );
  }
}
