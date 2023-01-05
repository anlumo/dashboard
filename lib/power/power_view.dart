import 'package:dashboard/models/cubit/power_request_cubit.dart';
import 'package:dashboard/power/power_chart.dart';
import 'package:dashboard/power/power_legend.dart';
import 'package:dashboard/utils/colors.dart';
import 'package:flutter/material.dart';

final powerMeasurementEntities = [
  PowerMeasurementPoint(
    id: 'sensor.wel_active_power_total',
    description: 'Rest',
    multiplier: 1000,
    color: wongColorblindPalette[1],
    children: [
      PowerMeasurementPoint(
        id: "sensor.metalab_active_power_total",
        description: 'OtterKitchenLib Rest',
        multiplier: 1000,
        color: wongColorblindPalette[2],
        children: [
          PowerMeasurementPoint(
            id: "sensor.metafridgepower_energy_power",
            description: 'Metafridge',
            multiplier: 1,
            color: wongColorblindPalette[3],
          ),
          PowerMeasurementPoint(
            id: "sensor.metafreezepower_energy_power",
            description: 'Metafreezer',
            multiplier: 1,
            color: wongColorblindPalette[4],
          ),
        ],
      ),
      PowerMeasurementPoint(
        id: "sensor.3dprinter_power",
        description: '3D Printers',
        multiplier: 1,
        color: wongColorblindPalette[5],
      ),
      PowerMeasurementPoint(
        id: "sensor.lasercutter_power",
        description: 'Lasercutter',
        multiplier: 1,
        color: wongColorblindPalette[6],
      ),
      PowerMeasurementPoint(
        id: "sensor.internetpower_energy_power",
        description: 'Internet + HAM Radio',
        multiplier: 1,
        color: wongColorblindPalette[7],
      ),
    ],
  ),
];

class PowerView extends StatelessWidget {
  const PowerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 250,
              child: PowerLegend(
                entities: powerMeasurementEntities,
                textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                colorSize: const Size(40, 20),
              ),
            ),
          ),
          PowerChart(
            entities: powerMeasurementEntities,
            averageWindow: const Duration(minutes: 60),
            verticalAxisStep: 24, // one day
            fontSize: 18,
            lineColor: colorScheme.secondary,
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [colorScheme.primary, colorScheme.secondary]),
            height: 700,
          ),
        ],
      ),
    );
  }

  static PowerRequestCubit generateCubit(BuildContext context) {
    final endTime = DateTime.now();
    final startTime = endTime.subtract(const Duration(
        days: 14)); // Home Assistant might not have that much data!

    final entityIds = powerMeasurementEntities
        .expand((entity) => entity.iterator())
        .map((entity) => entity.id)
        .toList(growable: false);

    return PowerRequestCubit()..load(startTime, endTime, entityIds);
  }
}
