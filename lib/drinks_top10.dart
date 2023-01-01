import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:dashboard/models/bloc/drinks_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrinksTop10 extends StatelessWidget {
  final int? category;
  final Color Function(int?)? colorGenerator;

  const DrinksTop10({Key? key, this.category, this.colorGenerator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DrinksBloc(),
      child: BlocBuilder<DrinksBloc, DrinksState>(
        builder: (context, state) {
          if (state is DrinksInitial) {
            context.read<DrinksBloc>().startTimer(const Duration(seconds: 5),
                '''SELECT name, SUM(count) AS total, category FROM drinks, eancodes WHERE drinks.date >= (CURRENT_DATE - INTERVAL '1 month') AND drinks.ean=eancodes.id ${category != null ? 'AND category = $category' : ''} GROUP BY drinks.ean,eancodes.name, eancodes.category ORDER BY total DESC LIMIT 10''');
          }
          if (state is DrinksHasData) {
            final List<List<ChartItem<double>>> rankedEntries = [
              state.drinks
                  .map((row) => ChartItem<double>(row['']!['total'].toDouble()))
                  .toList(growable: false)
            ];

            return Chart(
              state: ChartState(
                data: ChartData(rankedEntries),
                itemOptions: BarItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    barItemBuilder: (itemBuilderData) {
                      return BarItem(
                          radius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          color: colorGenerator != null
                              ? colorGenerator!(
                                  state.drinks[itemBuilderData.itemIndex]
                                      ['eancodes']!['category'])
                              : Colors.green);
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
                        children: state.drinks.asMap().entries.map((e) {
                          final idx = e.key;
                          final name = e.value['eancodes']!['name'];
                          return Positioned(
                              left: idx * itemWidth,
                              bottom: 0,
                              child: Container(
                                  clipBehavior: Clip.none,
                                  transform: Matrix4.translationValues(
                                      itemWidth / 2, 15.0, 0.0)
                                    ..rotateZ(pi / 4),
                                  child: Text(name,
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
