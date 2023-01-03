import 'package:charts_painter/chart.dart';
import 'package:dashboard/models/bloc/hass_bloc.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:dashboard/utils/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy-MM-dd');

class PowerChart extends StatelessWidget {
  final String entityId;
  final Duration averageWindow;
  final double verticalAxisStep;
  final double fontSize;
  final Color lineColor;
  final Gradient gradient;

  const PowerChart({
    Key? key,
    required this.entityId,
    required this.averageWindow,
    required this.verticalAxisStep,
    required this.fontSize,
    required this.lineColor,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hassBloc = getIt.get<HassBloc>();
    hassBloc.add(const HassConnect());

    return BlocBuilder<HassBloc, HassState>(
      bloc: hassBloc,
      builder: (context, state) {
        if (state is HassInitial || state is HassConnecting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary)),
            ],
          );
        }
        if (state is HassDisconnected) {
          return const Center(
              child: Icon(
            Icons.error_outline,
            color: Colors.red,
          ));
        }
        // only remaining option is connected state
        final hass = (state as HassConnected).hass;

        final endTime = DateTime.now();
        final startTime = endTime.subtract(const Duration(
            days: 14)); // Home Assistant might not have that much data!

        return FutureBuilder(
          future: hass.request("history/history_during_period", data: {
            "start_time": startTime.toIso8601String(),
            "end_time": endTime.toIso8601String(),
            "significant_changes_only": false,
            "include_start_time_state": true,
            "minimal_response": true,
            "no_attributes": true,
            "entity_ids": [
              entityId,
            ],
          }),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }
            if (!snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary)),
                ],
              );
            }
            final data = snapshot.data as Map<String, dynamic>;
            if (!data['success']) {
              return const Center(
                  child: Icon(
                Icons.error_outline,
                color: Colors.red,
              ));
            }
            final result = (data['result'] as Map<String, dynamic>)[entityId]
                as List<dynamic>;

            final values = result
                .map((event) {
                  try {
                    final s = double.parse(
                        (event as Map<String, dynamic>)['s']); // kWh
                    final lu = DateTime.fromMicrosecondsSinceEpoch(
                            ((event['lu'] as double) * 1e6).round())
                        .toLocal();
                    return Tuple(lu, s);
                  } catch (_) {
                    return null;
                  }
                })
                .where((element) => element != null)
                .toList();

            if (values.isEmpty) {
              return Center(
                  child: Flex(
                direction: Axis.horizontal,
                children: const [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  Text('No data'),
                ],
              ));
            }

            // update with real values
            final startTime = values.first!.item1;
            final endTime = values.last!.item1;

            final smoothedValues = <double>[];
            var valuesIdx = 0;
            var timeSlotEnd = startTime.add(averageWindow);
            double sum = 0;
            var count = 0;
            while (valuesIdx < values.length) {
              final value = values[valuesIdx];
              if (timeSlotEnd.isAfter(value!.item1)) {
                sum += value.item2;
                count++;
                valuesIdx++;
              } else {
                if (count > 0) {
                  smoothedValues.add(sum / count);
                } else {
                  smoothedValues.add(0);
                }
                sum = 0;
                count = 0;
                timeSlotEnd = timeSlotEnd.add(averageWindow);
              }
            }
            if (count > 0) {
              smoothedValues.add(sum / count);
              timeSlotEnd = timeSlotEnd.add(averageWindow);
            }
            final midnight = DateTime(endTime.year, endTime.month, endTime.day)
                .add(const Duration(days: 1));
            while (timeSlotEnd.isBefore(midnight)) {
              smoothedValues.add(0);
              timeSlotEnd = timeSlotEnd.add(averageWindow);
            }

            return Chart(
              state: ChartState(
                data: ChartData(
                  [
                    smoothedValues
                        .map((value) => ChartItem<double>(value * 1000))
                        .toList()
                  ],
                ),
                itemOptions: BarItemOptions(
                    barItemBuilder: (_) =>
                        const BarItem(color: Colors.transparent)),
                backgroundDecorations: [
                  GridDecoration(
                    showVerticalGrid: true,
                    verticalAxisStep: verticalAxisStep,
                    verticalAxisValueFromIndex: (value) => value.toString(),
                    textStyle: TextStyle(fontSize: fontSize),
                    horizontalAxisStep: 500,
                    horizontalAxisValueFromValue: (value) => '$value W',
                    showTopHorizontalValue: false,
                    showHorizontalValues: true,
                    gridColor: Colors.white.withOpacity(0.2),
                  ),
                  WidgetDecoration(widgetDecorationBuilder:
                      ((context, chartState, itemWidth, verticalMultiplier) {
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
                                  transform:
                                      Matrix4.translationValues(0.0, 20.0, 0.0),
                                  child: SizedBox(
                                    width: itemWidth * verticalAxisStep,
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      formatter.format(
                                          startTime.add(Duration(days: index))),
                                      softWrap: false,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: fontSize),
                                    ),
                                  )));
                        }),
                      ),
                    );
                  }))
                ],
                foregroundDecorations: [
                  SparkLineDecoration(
                    id: 'power_fill',
                    lineWidth: 2,
                    fill: true,
                    smoothPoints: true,
                    gradient: gradient,
                  ),
                  SparkLineDecoration(
                    id: 'power_line',
                    lineWidth: 2,
                    lineColor: lineColor,
                    smoothPoints: true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
