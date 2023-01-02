import 'package:dashboard/power/power_chart.dart';
import 'package:flutter/material.dart';

class PowerView extends StatelessWidget {
  const PowerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        PowerChart(
          entityId: "sensor.wel_active_power_total",
        ),
      ],
    );
  }
}
