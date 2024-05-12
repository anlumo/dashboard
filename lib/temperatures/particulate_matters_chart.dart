import 'package:charts_painter/chart.dart';
import 'package:dashboard/models/cubit/temperature_request_cubit.dart';
import 'package:dashboard/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:intl/intl.dart';
import 'package:list_ext/list_ext.dart';

final formatter = DateFormat('yyyy-MM-dd');

class ParticulateMattersChart extends StatelessWidget {
  final double height;
  final double fontSize;
  final Duration averageWindow;
  final double verticalAxisStep;

  const ParticulateMattersChart({
    super.key,
    this.fontSize = 16,
    this.height = 200,
    required this.averageWindow,
    required this.verticalAxisStep,
  });

  List<double> smoothValues(List<TemperatureEntry> values) {
    final smoothedValues = <double>[];

    final startTime = values.first.time;
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
    return smoothedValues;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemperatureRequestCubit, TemperatureRequestState>(
      builder: (context, state) {
        if (state is TemperatureRequestInitial || state is TemperatureRequestLoading) {
          return SizedBox(
            height: height,
            child: Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary),
              ),
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

        final values10 = (state as TemperatureRequestHasData).data['sensor.ag_one_pm_10_0'];
        final values2_5 = state.data['sensor.ag_one_pm_2_5'];
        final values1_0 = state.data['sensor.ag_one_pm_1_0'];

        if (values10 == null || values2_5 == null || values1_0 == null) {
          return Text(
            'Sensor not found',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        final smoothedValues10 = smoothValues(values10);
        final smoothedValues2_5 = smoothValues(values2_5);
        final smoothedValues1_0 = smoothValues(values1_0);

        final startTime = values10.first.time;
        final endTime = values10.last.time;

        final allValues = [
          ...smoothedValues10,
          ...smoothedValues2_5,
          ...smoothedValues1_0,
        ];

        final minimum = allValues.min().floorToDouble();
        final maximum = allValues.max().ceilToDouble();

        return LayoutGrid(
          areas: '''
            title
            chart
            legend
          ''',
          columnSizes: [1.fr],
          rowSizes: [auto, 1.fr, auto],
          rowGap: 8,
          children: [
            Text(
              'Particulate Matters',
              style: TextStyle(fontSize: fontSize, color: Colors.white),
            ).inGridArea('title'),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: LayoutBuilder(builder: (context, constraints) {
                return Chart(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  state: ChartState(
                      data: ChartData(
                        [
                          smoothedValues10.map((temp) => ChartItem<double>(temp)).toList(growable: false),
                          smoothedValues2_5.map((temp) => ChartItem<double>(temp)).toList(growable: false),
                          smoothedValues1_0.map((temp) => ChartItem<double>(temp)).toList(growable: false),
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
                          horizontalAxisValueFromValue: (value) => '${value / 10} µg/m³',
                          showTopHorizontalValue: false,
                          showHorizontalValues: true,
                          gridColor: Colors.white.withOpacity(0.2),
                        ),
                      ],
                      foregroundDecorations: [
                        SparkLineDecoration(
                          id: 'sensor.ag_one_pm_10_0_fill',
                          lineWidth: 2,
                          lineColor: wongColorblindPalette[7],
                          smoothPoints: true,
                        ),
                        SparkLineDecoration(
                          id: 'sensor.ag_one_pm_2_5_fill',
                          listIndex: 1,
                          lineWidth: 2,
                          lineColor: wongColorblindPalette[3],
                          smoothPoints: true,
                        ),
                        SparkLineDecoration(
                          id: 'sensor.ag_one_pm_1_0_fill',
                          listIndex: 2,
                          lineWidth: 2,
                          lineColor: wongColorblindPalette[5],
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
                        })),
                      ]),
                );
              }),
            ).inGridArea('chart'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [(10, wongColorblindPalette[7]), (2.5, wongColorblindPalette[3]), (1, wongColorblindPalette[5])]
                  .map(
                    (color) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: ColoredBox(color: color.$2),
                        ),
                        const SizedBox(width: 4),
                        Text('PM ${color.$1} µm'),
                        const SizedBox(width: 8),
                      ],
                    ),
                  )
                  .toList(growable: false),
            ).inGridArea('legend'),
          ],
        );
      },
    );
  }
}
