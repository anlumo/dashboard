import 'package:dashboard/main.dart';
import 'package:flutter/material.dart';

import 'drinks_history.dart';
import 'drinks_top10.dart';

class DrinksView extends StatelessWidget {
  const DrinksView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 8, 100),
          child: DrinksHistory(
            fontSize: 16,
            height: 260,
          ),
        ),
        Row(
          children: List.generate(
            5,
            (index) => Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DrinksTop10(
                  category: index == 0 ? null : index,
                  colorGenerator: (category) => category != null
                      ? kColorScheme
                          .firstWhere((cat) => cat.item1 == category)
                          .item2
                      : kColorScheme[0].item2,
                  fontSize: 16,
                  height: 190,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
