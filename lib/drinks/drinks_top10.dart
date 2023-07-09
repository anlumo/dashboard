import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:dashboard/models/cubit/drinks_request_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrinksTop10 extends StatelessWidget {
  final double height;
  final int? category;
  final Color Function(int?)? colorGenerator;
  final double fontSize;

  const DrinksTop10({Key? key, this.category, this.colorGenerator, this.fontSize = 12, this.height = 250})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrinksRequestCubit, DrinksRequestState>(
      builder: (context, state) => switch (state) {
        DrinksRequestInitial() || DrinksRequestLoading() => SizedBox(
            height: height,
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ),
        DrinksRequestFailed() => Center(
            child: Text(
              '${state.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        DrinksRequestHasData() => () {
            final drinks = state.top10InCategory(category ?? 0);
            final List<List<ChartItem<double>>> rankedEntries = [
              drinks.entries.map((row) => ChartItem<double>(row.total.toDouble())).toList(growable: false)
            ];

            return Chart(
              height: height,
              state: ChartState(
                data: ChartData(rankedEntries),
                itemOptions: BarItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    barItemBuilder: (itemBuilderData) {
                      return BarItem(
                          radius: const BorderRadius.vertical(top: Radius.circular(4)),
                          color: colorGenerator != null
                              ? colorGenerator!(drinks.entries[itemBuilderData.itemIndex].category)
                              : Colors.green);
                    }),
                backgroundDecorations: [
                  GridDecoration(
                    showVerticalGrid: false,
                    textStyle: TextStyle(fontSize: fontSize),
                    horizontalAxisStep: 5,
                    showHorizontalValues: true,
                    gridColor: Colors.white.withOpacity(0.2),
                  ),
                  WidgetDecoration(widgetDecorationBuilder: ((context, chartState, itemWidth, verticalMultiplier) {
                    return Container(
                      margin: chartState.defaultMargin,
                      clipBehavior: Clip.none,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: drinks.entries.indexed.map((e) {
                          final idx = e.$1;
                          final name = e.$2.name;
                          return Positioned(
                              left: idx * itemWidth,
                              bottom: 0,
                              child: Container(
                                  clipBehavior: Clip.none,
                                  transform: Matrix4.translationValues(itemWidth / 2, 20.0, 0.0)..rotateZ(pi / 4),
                                  child: Text(name,
                                      softWrap: false, style: TextStyle(color: Colors.white, fontSize: fontSize))));
                        }).toList(),
                      ),
                    );
                  }))
                ],
              ),
            );
          }(),
      },
    );
  }
}
