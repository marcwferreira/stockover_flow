import 'package:flutter/material.dart';
import '../data/models/company.dart';

class CheckboxList extends StatelessWidget {
  final List<Company> companies;
  final Function(bool, int) onChanged;

  const CheckboxList({
    required this.companies,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: companies.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text('${companies[index].symbol} - ${companies[index].name}'),
          subtitle: Text('Type: ${companies[index].type}'),
          value: companies[index].isFollowing,
          onChanged: (bool? value) {
            onChanged(value!, index);
          },
        );
      },
    );
  }
}
