import 'package:charts_painter/chart.dart';
import 'package:dashboard/models/cubit/temperature_request_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_ext/list_ext.dart';

@immutable
class TemperatureMeasurementPoint {
  final String id;
  final String description;
  final Color color;

  const TemperatureMeasurementPoint({
    required this.id,
    required this.description,
    required this.color,
  });

  @override
  String toString() => 'TemperatureMeasurementPoint($id, $description, $color)';
}

class TemperaturesChart extends StatelessWidget {
  final TemperatureMeasurementPoint entity;
  final double height;
  final double fontSize;
  final Duration averageWindow;

  const TemperaturesChart(
      {Key? key,
      required this.entity,
      this.fontSize = 16,
      this.height = 200,
      required this.averageWindow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemperatureRequestCubit, TemperatureRequestState>(
      builder: (context, state) {
        if (state is TemperatureRequestInitial ||
            state is TemperatureRequestLoading) {
          return SizedBox(
            height: height,
            child: Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          );
        }
        if (state is TemperatureRequestFailed) {
          return Center(
              child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).errorColor,
              ),
              Text('${state.error}',
                  style: TextStyle(color: Theme.of(context).errorColor)),
            ],
          ));
        }

        final values = (state as TemperatureRequestHasData).data[entity.id]!;

        final smoothedValues = <double>[];

        var time = values.first.time.add(averageWindow);
        int valuesIdx = 0;
        int count = 0;
        double sum = 0;
        while (valuesIdx < values.length) {
          final value = values[valuesIdx];
          if (time.isAfter(value.time)) {
            sum += value.temperature;
            count++;
            valuesIdx++;
          } else {
            if (count > 0) {
              smoothedValues.add(10 * sum / count);
            } else {
              smoothedValues.add(
                  smoothedValues[smoothedValues.length - 1]); // copy last value
            }
            sum = 0;
            count = 0;
            time = time.add(averageWindow);
          }
        }
        if (count > 0) {
          smoothedValues.add(10 * sum / count);
        }

        final minimum = smoothedValues.min().floorToDouble();
        final maximum = smoothedValues.max().ceilToDouble();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                entity.description,
                style: TextStyle(fontSize: fontSize, color: entity.color),
              ),
            ),
            Chart(
              height: height,
              state: ChartState(
                  data: ChartData(
                    [
                      smoothedValues
                          .map((temp) => ChartItem<double>(temp))
                          .toList(growable: false),
                    ],
                    axisMin: minimum,
                    axisMax: maximum,
                  ),
                  itemOptions: BarItemOptions(
                      barItemBuilder: (_) =>
                          const BarItem(color: Colors.transparent)),
                  backgroundDecorations: [
                    GridDecoration(
                      showVerticalGrid: true,
                      verticalAxisStep: 10,
                      verticalAxisValueFromIndex: (value) => value.toString(),
                      textStyle: TextStyle(fontSize: fontSize),
                      horizontalAxisStep: (maximum - minimum) / 5,
                      horizontalAxisValueFromValue: (value) =>
                          '${value / 10} °C',
                      showTopHorizontalValue: false,
                      showHorizontalValues: true,
                      gridColor: Colors.white.withOpacity(0.2),
                    ),
                  ],
                  foregroundDecorations: [
                    SparkLineDecoration(
                      id: '${entity.id}_fill',
                      lineWidth: 2,
                      lineColor: entity.color,
                      smoothPoints: true,
                    ),
                  ]),
            ),
          ],
        );
      },
    );
  }
}
