import 'package:charts_painter/chart.dart';
import 'package:dashboard/models/bloc/hass_bloc.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:dashboard/utils/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:list_ext/list_ext.dart';

final formatter = DateFormat('yyyy-MM-dd');

@immutable
class PowerMeasurementPoint {
  final String id;
  final String description;
  final double multiplier; // to W
  final Color color;
  final List<PowerMeasurementPoint> children;

  const PowerMeasurementPoint({
    required this.id,
    required this.description,
    required this.multiplier,
    required this.color,
    this.children = const [],
  });

  Iterable<PowerMeasurementPoint> iterator() sync* {
    yield this;
    for (final child in children) {
      yield* child.iterator();
    }
  }

  Iterable<PowerMeasurementPoint> depthFirstIterator() sync* {
    for (final child in children) {
      yield* child.depthFirstIterator();
    }
    yield this;
  }
}

class PowerChart extends StatelessWidget {
  final List<PowerMeasurementPoint> entities;
  final Duration averageWindow;
  final double verticalAxisStep;
  final double fontSize;
  final Color lineColor;
  final Gradient gradient;
  final double height;

  const PowerChart({
    Key? key,
    required this.entities,
    required this.averageWindow,
    required this.verticalAxisStep,
    required this.fontSize,
    required this.lineColor,
    required this.gradient,
    this.height = 300,
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

        final entityMap = Map.fromEntries(entities
            .expand((entity) => entity.iterator())
            .map((entity) => MapEntry(entity.id, entity)));

        return FutureBuilder(
          future: hass.request("history/history_during_period", data: {
            "start_time": startTime.toIso8601String(),
            "end_time": endTime.toIso8601String(),
            "significant_changes_only": false,
            "include_start_time_state": true,
            "minimal_response": true,
            "no_attributes": true,
            "entity_ids": entityMap.keys.toList(),
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
            final totalPower = snapshot.data as Map<String, dynamic>;
            if (!totalPower['success']) {
              return const Center(
                  child: Icon(
                Icons.error_outline,
                color: Colors.red,
              ));
            }
            final result = totalPower['result'] as Map<String, dynamic>;

            final values = <String, List<Tuple<DateTime, double>>>{};

            for (final kv in result.entries) {
              final entityId = kv.key;

              values[entityId] = kv.value
                  .map<Tuple<DateTime, double>?>((event) {
                    try {
                      final s = double.parse(event['s']); // kWh
                      final lu = DateTime.fromMicrosecondsSinceEpoch(
                              ((event['lu'] as double) * 1e6).round())
                          .toLocal();
                      return Tuple(lu, s);
                    } catch (_) {
                      return null;
                    }
                  })
                  .whereType<Tuple<DateTime, double>>()
                  .toList(growable: false);
            }

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
            final startTime = values.values
                .map((entity) => entity.first.item1)
                .reduce((previousValue, element) =>
                    previousValue.isAfter(element) ? element : previousValue);
            final endTime = values.values
                .map((entity) => entity.last.item1)
                .reduce((previousValue, element) =>
                    previousValue.isBefore(element) ? element : previousValue);

            final smoothedValues = <String, List<double>>{};
            for (final kv in values.entries) {
              final multiplier = entityMap[kv.key]!.multiplier;
              var valuesIdx = 0;
              var timeSlotEnd = startTime.add(averageWindow);
              double sum = 0;
              var count = 0;
              final smoothedResult = <double>[];
              while (valuesIdx < kv.value.length) {
                final value = kv.value[valuesIdx];
                if (timeSlotEnd.isAfter(value.item1)) {
                  sum += value.item2;
                  count++;
                  valuesIdx++;
                } else {
                  if (count > 0) {
                    smoothedResult.add(multiplier * sum / count);
                  } else {
                    smoothedResult.add(0);
                  }
                  sum = 0;
                  count = 0;
                  timeSlotEnd = timeSlotEnd.add(averageWindow);
                }
              }
              if (count > 0) {
                smoothedResult.add(multiplier * sum / count);
                timeSlotEnd = timeSlotEnd.add(averageWindow);
              }
              final midnight =
                  DateTime(endTime.year, endTime.month, endTime.day)
                      .add(const Duration(days: 1));
              while (timeSlotEnd.isBefore(midnight)) {
                smoothedResult.add(0);
                timeSlotEnd = timeSlotEnd.add(averageWindow);
              }
              smoothedValues[kv.key] = smoothedResult;
            }

            // subtract subentities from their parents
            // we have to go depth first to resolve multi-level dependencies
            for (final entity
                in entities.expand((entity) => entity.depthFirstIterator())) {
              if (entity.children.isNotEmpty) {
                final values = smoothedValues[entity.id]!;
                final childrenValues = entity.children
                    .map((child) => smoothedValues[child.id])
                    .toList(growable: false);
                for (final index in Iterable.generate(values.length)) {
                  values[index] -=
                      childrenValues.map((values) => values![index]).sum();
                }
              }
            }

            final entityOrder = entities
                .expand((element) => element.depthFirstIterator())
                .toList(growable: false)
                .reversed
                .toList(growable: false);

            return Chart(
              height: height,
              state: ChartState(
                data: ChartData(
                  entityOrder
                      .map((entity) => smoothedValues[entity.id]!
                          .map((value) => ChartItem<double>(value))
                          .toList(growable: false))
                      .toList(growable: false),
                  dataStrategy: const StackDataStrategy(),
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
                  ...entityOrder
                      .mapIndex((entity, index) => SparkLineDecoration(
                            id: '${entity.id}_fill',
                            lineWidth: 2,
                            lineColor: entity.color,
                            smoothPoints: true,
                            listIndex: index,
                            fill: true,
                          )),
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
                // foregroundDecorations: entityOrder
                //     .mapIndex((entity, index) => SparkLineDecoration(
                //           id: '${entity.id}_line',
                //           lineWidth: 2,
                //           lineColor: entity.color,
                //           smoothPoints: true,
                //           listIndex: index,
                //         ))
                //     .toList(growable: false)
              ),
            );
          },
        );
      },
    );
  }
}
