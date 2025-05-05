import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:stock_overflow/utils/config/color_config.dart';

class PerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String selectedTimeUnit;
  final ColorConfig colorConfig;

  const PerformanceChart({
    Key? key,
    required this.data,
    required this.selectedTimeUnit,
    required this.colorConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String themeMode = isDarkMode ? 'dark' : 'light';
    Color positiveChange = colorConfig.getColor(themeMode, 'positiveChange');
    Color negativeChange = colorConfig.getColor(themeMode, 'negativeChange');

    double minValue = data.map((e) => e['low'] as double).reduce((a, b) => a < b ? a : b);
    double maxValue = data.map((e) => e['high'] as double).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Chart(
          data: data,
          variables: {
            'time': Variable(
              accessor: (Map datumn) => datumn['time'].toString(),
              scale: OrdinalScale(
                tickCount: 4,
                formatter: (String date) {
                  final dateTime = DateTime.parse(date);
                  return selectedTimeUnit == '1h'
                      ? '${dateTime.hour}:${dateTime.minute}'
                      : selectedTimeUnit == '1D'
                      ? '${dateTime.hour}:${dateTime.minute}'
                      : '${dateTime.month}/${dateTime.day}';
                },
              ),
            ),
            'open': Variable(
              accessor: (Map datumn) => datumn['open'] as num,
              scale: LinearScale(min: minValue, max: maxValue),
            ),
            'high': Variable(
              accessor: (Map datumn) => datumn['high'] as num,
              scale: LinearScale(min: minValue, max: maxValue),
            ),
            'low': Variable(
              accessor: (Map datumn) => datumn['low'] as num,
              scale: LinearScale(min: minValue, max: maxValue),
            ),
            'close': Variable(
              accessor: (Map datumn) => datumn['close'] as num,
              scale: LinearScale(min: minValue, max: maxValue),
            ),
          },
          marks: [
            CustomMark(
              position: Varset('time') *
                  (Varset('open') + Varset('high') + Varset('low') + Varset('close')),
              shape: ShapeEncode(value: CandlestickShape()),
              color: ColorEncode(
                encoder: (tuple) => tuple['close'] >= tuple['open'] ? positiveChange : negativeChange,
              ),
            ),
          ],
          axes: [
            Defaults.horizontalAxis,
            Defaults.verticalAxis,
          ],
          coord: RectCoord(
            horizontalRangeUpdater: Defaults.horizontalRangeEvent,
            verticalRangeUpdater: Defaults.verticalRangeEvent,
          ),
        ),
      ),
    );
  }
}
