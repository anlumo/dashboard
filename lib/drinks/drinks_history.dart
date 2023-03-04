import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:dashboard/main.dart';
import 'package:dashboard/models/cubit/drinks_request_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy-MM-dd');

class DrinksHistory extends StatelessWidget {
  final double height;
  final double fontSize;
  const DrinksHistory({Key? key, this.fontSize = 16, this.height = 400})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrinksRequestCubit, DrinksRequestState>(
      builder: (context, state) {
        if (state is DrinksRequestInitial || state is DrinksRequestLoading) {
          return SizedBox(
            height: height,
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          );
        }
        if (state is DrinksRequestFailed) {
          return Center(
            child: Text(
              '${state.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final drinks = (state as DrinksRequestHasData).history;

        final categoryCount = drinks
                .map((row) => row['eancodes']!['category'] as int? ?? 0)
                .fold(0, max<int>) +
            1;
        final List<DateTime> dates = Set<DateTime>.from(
                drinks.map((row) => row['drinks']!['date']! as DateTime))
            .toList(growable: false);
        dates.sort();
        final List<List<ChartItem<double>>> dateEntries = List.generate(
            categoryCount, (_) => List.filled(dates.length, ChartItem(0)));

        for (final row in drinks) {
          final category = row['eancodes']!['category'] ?? 0;
          final dateIndex = dates.indexOf(row['drinks']!['date']!);

          var categoryIndex = 0;
          for (final c in kColorScheme.asMap().entries) {
            if (c.value.item1 == category) {
              categoryIndex = c.key;
              break;
            }
          }

          dateEntries[categoryIndex][dateIndex] = ChartItem(
              dateEntries[categoryIndex][dateIndex].max! +
                  row['drinks']!['count'].toDouble());
        }

        return Chart(
          height: height,
          state: ChartState(
            data:
                ChartData(dateEntries, dataStrategy: const StackDataStrategy()),
            itemOptions: BarItemOptions(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                barItemBuilder: (itemBuilderData) {
                  return BarItem(
                      radius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                      color: kColorScheme[
                              itemBuilderData.listIndex % kColorScheme.length]
                          .item2);
                }),
            backgroundDecorations: [
              GridDecoration(
                showVerticalGrid: false,
                textStyle: TextStyle(fontSize: fontSize),
                horizontalAxisStep: 5,
                showHorizontalValues: true,
                gridColor: Colors.white.withOpacity(0.2),
              ),
              WidgetDecoration(widgetDecorationBuilder:
                  ((context, chartState, itemWidth, verticalMultiplier) {
                return Container(
                  margin: chartState.defaultMargin,
                  clipBehavior: Clip.none,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: dates.asMap().entries.map((e) {
                      final idx = e.key;
                      final date = e.value;
                      return Positioned(
                          left: idx * itemWidth,
                          bottom: 0,
                          child: Container(
                              clipBehavior: Clip.none,
                              transform: Matrix4.translationValues(
                                  itemWidth / 2, 20.0, 0.0)
                                ..rotateZ(pi / 4),
                              child: Text(formatter.format(date),
                                  softWrap: false,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSize))));
                    }).toList(),
                  ),
                );
              }))
            ],
          ),
        );
      },
    );
  }
}
