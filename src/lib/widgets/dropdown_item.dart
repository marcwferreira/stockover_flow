import 'package:flutter/material.dart';
import 'package:stock_overflow/data/models/company.dart';

class DropdownItem extends StatefulWidget {
  final Company company;
  final bool isSelected;
  final Function(String) toggleComparison;

  const DropdownItem({
    Key? key,
    required this.company,
    required this.isSelected,
    required this.toggleComparison,
  }) : super(key: key);

  @override
  State<DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<DropdownItem> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant DropdownItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      setState(() {
        isSelected = widget.isSelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${widget.company.symbol} - ${widget.company.name}'),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: isSelected,
            onChanged: (bool value) {
              bool toggleSuccess =
              widget.toggleComparison(widget.company.symbol);
              if (!toggleSuccess && value) {
                setState(() {
                  isSelected = false;
                });
              } else {
                setState(() {
                  isSelected = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
