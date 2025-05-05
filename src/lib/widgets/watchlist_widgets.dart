import 'package:flutter/material.dart';
import 'package:stock_overflow/data/models/company.dart';
import 'package:stock_overflow/utils/config/color_config.dart';

Widget buildCompanyCheckboxListTile(
    BuildContext context,
    Company company,
    List<Company> selectedCompanies,
    ColorConfig colorConfig,
    void Function(bool?, Company) onCheckboxChanged,
    ) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? colorConfig.getColor('dark', 'card')
          : colorConfig.getColor('light', 'card'),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: StatefulBuilder(
      builder: (context, innerSetState) {
        return CheckboxListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company.symbol,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorConfig.getColor('dark', 'text')
                      : colorConfig.getColor('light', 'text'),
                ),
              ),
              Text(
                company.name,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorConfig.getColor('dark', 'text')
                      : colorConfig.getColor('light', 'text'),
                ),
              ),
            ],
          ),
          subtitle: Text(
            company.type,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? colorConfig.getColor('dark', 'text')
                  : colorConfig.getColor('light', 'text'),
            ),
          ),
          value: company.isFollowing,
          onChanged: (bool? value) {
            innerSetState(() {
              onCheckboxChanged(value, company);
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          side: MaterialStateBorderSide.resolveWith(
                (states) => const BorderSide(width: 2.0, color: Colors.black),
          ),
          checkColor: Colors.white,
          activeColor: Theme.of(context).primaryColor,
          tristate: false,
        );
      },
    ),
  );
}

Widget buildDraggableListItem(
    BuildContext context,
    int index,
    bool dragged,
    List<Company> selectedCompanies,
    void Function(int data, int index) handleAccept,
    ColorConfig colorConfig,
    ) {
  if (index == selectedCompanies.length) {
    return Opacity(
      opacity: 0.0,
      child: buildDraggableListItem(context, index - 1, false, selectedCompanies, handleAccept, colorConfig),
    );
  }

  final company = selectedCompanies[index];

  return LongPressDraggable<int>(
    data: index,
    feedback: Material(
      elevation: dragged ? 20.0 : 0.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? colorConfig.getColor('dark', 'card')
              : colorConfig.getColor('light', 'card'),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company.symbol,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorConfig.getColor('dark', 'text')
                      : colorConfig.getColor('light', 'text'),
                ),
              ),
              Text(
                company.name,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorConfig.getColor('dark', 'text')
                      : colorConfig.getColor('light', 'text'),
                ),
              ),
            ],
          ),
          subtitle: Text(
            company.type,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? colorConfig.getColor('dark', 'text')
                  : colorConfig.getColor('light', 'text'),
            ),
          ),
        ),
      ),
    ),
    childWhenDragging: Container(),
    child: DragTarget<int>(
      onAccept: (int data) {
        handleAccept(data, index);
      },
      builder: (BuildContext context, List<int?> candidateData, List<dynamic> rejectedData) {
        List<Widget> children = [];

        if (candidateData.isNotEmpty) {
          children.add(
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[600]!, width: 2.0),
              ),
              child: Opacity(
                opacity: 0.5,
                child: buildDraggableListItem(context, candidateData[0]!, true, selectedCompanies, handleAccept, colorConfig),
              ),
            ),
          );
        }
        children.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? colorConfig.getColor('dark', 'card')
                  : colorConfig.getColor('light', 'card'),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.symbol,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? colorConfig.getColor('dark', 'text')
                          : colorConfig.getColor('light', 'text'),
                    ),
                  ),
                  Text(
                    company.name,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? colorConfig.getColor('dark', 'text')
                          : colorConfig.getColor('light', 'text'),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                company.type,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorConfig.getColor('dark', 'text')
                      : colorConfig.getColor('light', 'text'),
                ),
              ),
              trailing: const Icon(Icons.menu),
            ),
          ),
        );

        return Column(
          children: children,
        );
      },
    ),
  );
}
