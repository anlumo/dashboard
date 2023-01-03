import 'package:dashboard/power/power_chart.dart';
import 'package:flutter/material.dart';

class PowerView extends StatelessWidget {
  const PowerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PowerChart(
          entityId: "sensor.wel_active_power_total",
          averageWindow: const Duration(minutes: 60),
          verticalAxisStep: 24, // one day
          fontSize: 18,
          lineColor: colorScheme.secondary,
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [colorScheme.primary, colorScheme.secondary]),
        ),
      ],
    );
  }
}
