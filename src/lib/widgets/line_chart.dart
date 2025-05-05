import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:stock_overflow/utils/config/color_config.dart';

class LineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String selectedTimeUnit;
  final ColorConfig colorConfig;

  const LineChart({
    Key? key,
    required this.data,
    required this.selectedTimeUnit,
    required this.colorConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert data[0] to a List<Map<dynamic, dynamic>>
    List<Map<dynamic, dynamic>> dataValues = [];
    Map<String, Color> colors = {};

    for (var i = 0; i < data.length; i++) {
      var symbol = data[i]['symbol'];
      for (var j = 0; j < data[i]['data'].length; j++) {
        dataValues.add({
          'time': data[i]['data'][j]['time'],
          'value': data[i]['data'][j]['value'],
          'symbol': symbol,
        });

        colors[symbol] = data[i]['color'];
      }
    }

    double minValue = dataValues
            .map((e) => e['value'] as double)
            .reduce((a, b) => a < b ? a : b);
    double maxValue = dataValues
            .map((e) => e['value'] as double)
            .reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 350,
      height: 300,
      child: Chart(
        data: dataValues,
        variables: {
          'time': Variable(
            accessor: (Map datum) => datum['time'].toString(),
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
          'value': Variable(
            accessor: (Map datumn) => datumn['value'] as num,
            scale: LinearScale(min: minValue, max: maxValue),
          ),
          'symbol': Variable(
            accessor: (Map datumn) => datumn['symbol'].toString(),
          ),
        },
        marks: [
          LineMark(
            position: Varset('time') * Varset('value') / Varset('symbol'),
            shape: ShapeEncode(value: BasicLineShape()),
            selected: {
              'touchMove': {1}
            },
            color: ColorEncode(
              encoder: (Tuple t) {
                final symbol = t['symbol'] as String;
                return colors[symbol] ?? Colors.blue;
              },
            ),
          )
        ],
        coord: RectCoord(),
        axes: [
          Defaults.horizontalAxis,
          Defaults.verticalAxis,
        ],
        selections: {
          'touchMove': PointSelection(
            on: {
              GestureType.scaleUpdate,
              GestureType.tapDown,
              GestureType.longPressMoveUpdate
            },
            dim: Dim.x,
          )
        },
        tooltip: TooltipGuide(
          followPointer: [false, true],
          align: Alignment.topLeft,
          offset: const Offset(-20, -20),
          selections: {'touchMove'},
        ),
        crosshair: CrosshairGuide(followPointer: [false, true]),
      ),
    );
  }
}
