import 'package:dashboard/power/power_chart.dart';
import 'package:flutter/material.dart';

class PowerView extends StatelessWidget {
  const PowerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        PowerChart(),
      ],
    );
  }
}
