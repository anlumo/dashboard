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
          entities: [
            PowerMeasurementPoint(
              id: 'sensor.wel_active_power_total',
              multiplier: 1000,
              color: colorScheme.secondary,
              children: const [
                PowerMeasurementPoint(
                  id: "sensor.metalab_active_power_total",
                  multiplier: 1000,
                  color: Colors.orange,
                  children: [
                    PowerMeasurementPoint(
                      id: "sensor.metafridgepower_energy_power",
                      multiplier: 1,
                      color: Colors.purple,
                    ),
                    PowerMeasurementPoint(
                      id: "sensor.metafreezepower_energy_power",
                      multiplier: 1,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
                PowerMeasurementPoint(
                  id: "sensor.3dprinter_power",
                  multiplier: 1,
                  color: Colors.blue,
                ),
                PowerMeasurementPoint(
                  id: "sensor.lasercutter_power",
                  multiplier: 1,
                  color: Colors.yellow,
                ),
                PowerMeasurementPoint(
                  id: "sensor.internetpower_energy_power",
                  multiplier: 1,
                  color: Colors.brown,
                ),
              ],
            ),
          ],
          averageWindow: const Duration(minutes: 60),
          verticalAxisStep: 24, // one day
          fontSize: 18,
          lineColor: colorScheme.secondary,
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [colorScheme.primary, colorScheme.secondary]),
          height: 800,
        ),
      ],
    );
  }
}
