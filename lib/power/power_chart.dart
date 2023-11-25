import 'package:charts_painter/chart.dart';
import 'package:dashboard/models/cubit/power_request_cubit.dart';
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
    super.key,
    required this.entities,
    required this.averageWindow,
    required this.verticalAxisStep,
    required this.fontSize,
    required this.lineColor,
    required this.gradient,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerRequestCubit, PowerRequestState>(builder: (context, state) {
      if (state is PowerRequestInitial || state is PowerRequestLoading) {
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
      if (state is PowerRequestFailed) {
        return Center(
            child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            Text('${state.error}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ));
      }

      final entityMap =
          Map.fromEntries(entities.expand((entity) => entity.iterator()).map((entity) => MapEntry(entity.id, entity)));

      final totalPower = (state as PowerRequestHasData).data;
      if (!totalPower['success']) {
        return const Center(
            child: Icon(
          Icons.error_outline,
          color: Colors.red,
        ));
      }
      final result = totalPower['result'] as Map<String, dynamic>;

      final values = <String, List<(DateTime, double)>>{};

      for (final kv in result.entries) {
        final entityId = kv.key;

        values[entityId] = kv.value
            .map<(DateTime, double)?>((event) {
              try {
                final s = double.parse(event['s']); // kWh
                final lu = DateTime.fromMicrosecondsSinceEpoch(((event['lu'] as double) * 1e6).round()).toLocal();
                return (lu, s);
              } catch (_) {
                return null;
              }
            })
            .whereType<(DateTime, double)>()
            .toList(growable: false);
      }

      if (values.isEmpty) {
        return Center(
            child: Flex(
          direction: Axis.horizontal,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const Text('No data'),
          ],
        ));
      }

      // update with real values
      final startTime = values.values
          .map((entity) => entity.first.$1)
          .reduce((previousValue, element) => previousValue.isAfter(element) ? element : previousValue);
      final endTime = values.values
          .map((entity) => entity.last.$1)
          .reduce((previousValue, element) => previousValue.isBefore(element) ? element : previousValue);

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
          if (timeSlotEnd.isAfter(value.$1)) {
            sum += value.$2;
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
        } else {
          smoothedResult.add(0);
        }

        final midnight = DateTime(endTime.year, endTime.month, endTime.day).add(const Duration(days: 1));
        while (timeSlotEnd.isBefore(midnight)) {
          smoothedResult.add(0);
          timeSlotEnd = timeSlotEnd.add(averageWindow);
        }
        smoothedValues[kv.key] = smoothedResult;
      }

      // subtract subentities from their parents
      // we have to go depth first to resolve multi-level dependencies
      for (final entity in entities.expand((entity) => entity.depthFirstIterator())) {
        if (entity.children.isNotEmpty) {
          final values = smoothedValues[entity.id]!;
          final childrenValues = entity.children.map((child) => smoothedValues[child.id]).toList(growable: false);
          for (final index in Iterable.generate(values.length)) {
            values[index] -= childrenValues.map((values) => values?[index] ?? 0).sum();
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
                .map((entity) =>
                    smoothedValues[entity.id]?.map((value) => ChartItem<double>(value)).toList(growable: false) ?? [])
                .toList(growable: false),
            dataStrategy: const StackDataStrategy(),
          ),
          itemOptions: BarItemOptions(barItemBuilder: (_) => const BarItem(color: Colors.transparent)),
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
            ...entityOrder.mapIndex((entity, index) => SparkLineDecoration(
                  id: '${entity.id}_fill',
                  lineWidth: 2,
                  lineColor: entity.color,
                  smoothPoints: true,
                  listIndex: index,
                  fill: true,
                )),
            WidgetDecoration(widgetDecorationBuilder: ((context, chartState, itemWidth, verticalMultiplier) {
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
          ],
        ),
      );
    });
  }
}
