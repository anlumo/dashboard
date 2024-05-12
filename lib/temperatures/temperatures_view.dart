import 'package:dashboard/models/cubit/temperature_request_cubit.dart';
import 'package:dashboard/temperatures/particulate_matters_chart.dart';
import 'package:dashboard/temperatures/temperatures_chart.dart';
import 'package:dashboard/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

final temperatureMeasurementEntities = [
  TemperatureMeasurementPoint(
    id: 'sensor.ag_one_temperature',
    description: 'Otter Space Temperature',
    color: wongColorblindPalette[1],
    gridArea: 'temp',
  ),
  TemperatureMeasurementPoint(
    id: 'sensor.ag_one_humidity',
    description: 'Otter Space Humidity',
    valueFormatter: (value) => '${(value / 10).round()}%',
    color: wongColorblindPalette[2],
    gridArea: 'humidity',
  ),
  TemperatureMeasurementPoint(
    id: 'sensor.ag_one_co2',
    description: 'Otter Space CO₂',
    valueFormatter: (value) => '${(value / 10).round()} ppm',
    color: wongColorblindPalette[4],
    gridArea: 'co2',
  ),
  TemperatureMeasurementPoint(
    id: 'sensor.antishutdown_ds18b20_temperature',
    description: 'Entrance',
    color: wongColorblindPalette[6],
    gridArea: 'entrance',
  ),
  TemperatureMeasurementPoint(
    id: 'sensor.ag_one_pm_1_0',
    description: 'PM 1.0',
    color: wongColorblindPalette[6],
  ),
  TemperatureMeasurementPoint(
    id: 'sensor.ag_one_pm_2_5',
    description: 'PM 2.5',
    color: wongColorblindPalette[7],
  ),
  TemperatureMeasurementPoint(
    id: 'sensor.ag_one_pm_10_0',
    description: 'PM 10.0',
    color: wongColorblindPalette[1],
  ),
  TemperatureMeasurementPoint(
    id: 'sensor.ag_one_pm_0_3',
    description: 'Particulate Matters ≤0.3 µm',
    valueFormatter: (value) => '${(value / 10).round()} /dL',
    color: wongColorblindPalette[5],
    gridArea: 'pm03',
  ),
];

class TemperaturesView extends StatelessWidget {
  const TemperaturesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutGrid(
        areas: '''
          temp     particulate
          humidity particulate
          co2      pm03
          entrance .
        ''',
        columnSizes: [1.fr, 1.fr],
        rowSizes: [1.fr, 1.fr, 1.fr, 1.fr],
        columnGap: 8,
        rowGap: 16,
        children: [
          ...temperatureMeasurementEntities
              .map((entity) => entity.gridArea != null
                  ? TemperaturesChart(
                      entity: entity,
                      averageWindow: const Duration(minutes: 5),
                      verticalAxisStep: 24 * 60 / 5, // one day
                    ).inGridArea(entity.gridArea!)
                  : null)
              .whereType<NamedAreaGridPlacement>(),
          const ParticulateMattersChart(
            averageWindow: Duration(minutes: 5),
            verticalAxisStep: 24 * 60 / 5, // one day
          ).inGridArea('particulate'),
        ],
      ),
    );
  }

  static TemperatureRequestCubit generateCubit(BuildContext context) {
    final endTime = DateTime.now();
    final startTime = endTime.subtract(const Duration(days: 2)); // Home Assistant might not have that much data!

    final entityIds = temperatureMeasurementEntities.map((entity) => entity.id).toList(growable: false);

    return TemperatureRequestCubit()..load(startTime, endTime, entityIds);
  }
}
