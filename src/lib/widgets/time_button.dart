import 'package:flutter/material.dart';
import 'package:stock_overflow/utils/config/color_config.dart';

class TimeButton extends StatelessWidget {
  final String timeUnit;
  final bool isSelected;
  final Function(String) onPressed;
  final Color buttonUnselected;
  final Color buttonSelected;
  final Color buttonText;

  const TimeButton({
    Key? key,
    required this.timeUnit,
    required this.isSelected,
    required this.onPressed,
    required this.buttonUnselected,
    required this.buttonSelected,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed(timeUnit);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? buttonSelected : buttonUnselected,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      child: Text(
        timeUnit,
        style: TextStyle(fontSize: 12, color: buttonText),
      ),
    );
  }
}

class TimeUnitsRow extends StatefulWidget {
  final List<String> timeUnits;
  final Function(String) onPressed;
  final ColorConfig colorConfig;
  final String selectedTimeUnit;

  const TimeUnitsRow({
    Key? key,
    required this.onPressed,
    required this.colorConfig,
    this.timeUnits = const ['1h', '1D', '1W', '1M', '1Y'],
    required this.selectedTimeUnit,
  }) : super(key: key);

  @override
  State<TimeUnitsRow> createState() => _TimeUnitsRowState();
}

class _TimeUnitsRowState extends State<TimeUnitsRow> {
  late String _selectedTimeUnit;

  @override
  void initState() {
    super.initState();
    _selectedTimeUnit = widget.selectedTimeUnit;
  }

  void _onTimeUnitPressed(String timeUnit) {
    setState(() {
      _selectedTimeUnit = timeUnit;
    });
    widget.onPressed(timeUnit);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String themeMode = isDarkMode ? 'dark' : 'light';
    Color buttonUnselected = widget.colorConfig.getColor(themeMode, 'button_unselected');
    Color buttonSelected = widget.colorConfig.getColor(themeMode, 'button_selected');
    Color buttonText = widget.colorConfig.getColor(themeMode, 'button_text');

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 4.0,
        children: widget.timeUnits.map((timeUnit) {
          return TimeButton(
            timeUnit: timeUnit,
            isSelected: _selectedTimeUnit == timeUnit,
            onPressed: _onTimeUnitPressed,
            buttonUnselected: buttonUnselected,
            buttonSelected: buttonSelected,
            buttonText: buttonText,
          );
        }).toList(),
      ),
    );
  }
}
