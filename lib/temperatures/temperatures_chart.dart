import 'package:charts_painter/chart.dart';
import 'package:dashboard/models/cubit/temperature_request_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:intl/intl.dart';
import 'package:list_ext/list_ext.dart';

final formatter = DateFormat('yyyy-MM-dd');

@immutable
class TemperatureMeasurementPoint {
  final String id;
  final String description;
  final Color color;
  final String Function(int)? valueFormatter;
  final String? gridArea;

  const TemperatureMeasurementPoint({
    required this.id,
    required this.description,
    required this.color,
    this.gridArea,
    this.valueFormatter,
  });

  @override
  String toString() => 'TemperatureMeasurementPoint($id, $description, $color)';
}

class TemperaturesChart extends StatelessWidget {
  final TemperatureMeasurementPoint entity;
  final double fontSize;
  final Duration averageWindow;
  final double verticalAxisStep;

  const TemperaturesChart({
    super.key,
    required this.entity,
    this.fontSize = 16,
    required this.averageWindow,
    required this.verticalAxisStep,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemperatureRequestCubit, TemperatureRequestState>(
      builder: (context, state) {
        if (state is TemperatureRequestInitial || state is TemperatureRequestLoading) {
          return Center(
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary),
            ),
          );
        }
        if (state is TemperatureRequestFailed) {
          final color = Theme.of(context).colorScheme.error;
          return Center(
              child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: color,
              ),
              Text('${state.error}', style: TextStyle(color: color)),
            ],
          ));
        }

        final values = (state as TemperatureRequestHasData).data[entity.id]!;

        final smoothedValues = <double>[];

        final startTime = values.first.time;
        final endTime = values.last.time;
        var time = startTime.add(averageWindow);
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
              smoothedValues.add(smoothedValues[smoothedValues.length - 1]); // copy last value
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

        return LayoutGrid(
          areas: '''
            title
            chart
          ''',
          columnSizes: [1.fr],
          rowSizes: [auto, 1.fr],
          rowGap: 4,
          children: [
            Text(
              entity.description,
              style: TextStyle(fontSize: fontSize, color: entity.color),
            ).inGridArea('title'),
            ClipRect(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: LayoutBuilder(builder: (context, constraints) {
                  return Chart(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    state: ChartState(
                        data: ChartData(
                          [
                            smoothedValues.map((temp) => ChartItem<double>(temp)).toList(growable: false),
                          ],
                          axisMin: minimum,
                          axisMax: maximum,
                        ),
                        itemOptions: BarItemOptions(barItemBuilder: (_) => const BarItem(color: Colors.transparent)),
                        backgroundDecorations: [
                          GridDecoration(
                            showVerticalGrid: true,
                            verticalAxisStep: verticalAxisStep,
                            verticalAxisValueFromIndex: (value) => value.toString(),
                            textStyle: TextStyle(fontSize: fontSize),
                            horizontalAxisStep: (maximum - minimum) / 5,
                            horizontalAxisValueFromValue: entity.valueFormatter ?? (value) => '${value / 10} °C',
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
                          WidgetDecoration(
                              widgetDecorationBuilder: ((context, chartState, itemWidth, verticalMultiplier) {
                            final duration = endTime.difference(startTime);

                            return Container(
                              margin: chartState.defaultMargin,
                              clipBehavior: Clip.none,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: List.generate(duration.inDays + 1, (index) {
                                  return Positioned(
                                      left: index * itemWidth * verticalAxisStep,
                                      bottom: 0,
                                      child: Container(
                                          clipBehavior: Clip.none,
                                          transform: Matrix4.translationValues(0.0, 20.0, 0.0),
                                          child: SizedBox(
                                            width: itemWidth * verticalAxisStep,
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              formatter.format(startTime.add(Duration(days: index))),
                                              softWrap: false,
                                              style: TextStyle(color: Colors.white, fontSize: fontSize),
                                            ),
                                          )));
                                }),
                              ),
                            );
                          }))
                        ]),
                  );
                }),
              ),
            ).inGridArea('chart'),
          ],
        );
      },
    );
  }
}
