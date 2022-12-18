import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:dashboard/models/bloc/drinks_bloc.dart';
import 'package:dashboard/utils/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

final kColorScheme = [
  Tuple(0, Colors.grey), // other
  Tuple(2, Colors.brown), // beer
  Tuple(3, Colors.green), // Wostok
  Tuple(4, Colors.black), // Cola
  Tuple(1, Colors.yellow), // Mate
];

final formatter = DateFormat('yyyy-MM-dd');

class DrinksTop10 extends StatelessWidget {
  const DrinksTop10({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DrinksBloc(),
      child: BlocBuilder<DrinksBloc, DrinksState>(
        builder: (context, state) {
          if (state is DrinksInitial) {
            context
                .read<DrinksBloc>()
                .startTimer(const Duration(seconds: 5), '''SELECT
                    date, category, count
                  FROM drinks, eancodes
                  WHERE
                    date BETWEEN (NOW() - interval '30 days') AND NOW() AND
                    drinks.ean = eancodes.id''');
          }
          if (state is DrinksHasData) {
            final categoryCount = state.drinks
                    .map((row) => row['eancodes']!['category'] as int? ?? 0)
                    .fold(0, max<int>) +
                1;
            final List<DateTime> dates = Set<DateTime>.from(state.drinks
                    .map((row) => row['drinks']!['date']! as DateTime))
                .toList(growable: false);
            dates.sort();
            final List<List<ChartItem<double>>> dateEntries = List.generate(
                categoryCount, (_) => List.filled(dates.length, ChartItem(0)));

            for (final row in state.drinks) {
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
              state: ChartState(
                data: ChartData(dateEntries,
                    dataStrategy: const StackDataStrategy()),
                itemOptions: BarItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    barItemBuilder: (itemBuilderData) {
                      return BarItem(
                          radius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          color: kColorScheme[itemBuilderData.listIndex %
                                  kColorScheme.length]
                              .item2);
                    }),
                backgroundDecorations: [
                  GridDecoration(
                    showVerticalGrid: false,
                    textStyle: const TextStyle(fontSize: 12),
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
                                      itemWidth / 2, 15.0, 0.0)
                                    ..rotateZ(pi / 4),
                                  child: Text(formatter.format(date),
                                      softWrap: false,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12))));
                        }).toList(),
                      ),
                    );
                  }))
                ],
              ),
            );
          } else if (state is DrinksError) {
            return Center(
              child: Text(
                state.error.message,
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            );
          } else {
            return Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary),
              ),
            );
          }
        },
      ),
    );
  }
}
