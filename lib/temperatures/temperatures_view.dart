import 'package:dashboard/models/cubit/temperature_request_cubit.dart';
import 'package:dashboard/temperatures/temperatures_chart.dart';
import 'package:dashboard/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final temperatureMeasurementEntities = [
  TemperatureMeasurementPoint(
      id: 'sensor.temp_mainroom',
      description: 'Otter Space',
      color: wongColorblindPalette[1]),
  TemperatureMeasurementPoint(
      id: 'sensor.air_quality_sensor_temperature',
      description: 'Otter Space Air Quality',
      color: wongColorblindPalette[2]),
  // TemperatureMeasurementPoint(
  //     id: 'sensor.weltemp_temperature',
  //     description: 'Whatever Lab',
  //     color: wongColorblindPalette[3]),
  TemperatureMeasurementPoint(
      id: 'sensor.air_quality_sensor_co2',
      description: 'Otter Space CO₂',
      valueFormatter: (value) => '${(value / 10).round()} ppm',
      color: wongColorblindPalette[4]),
  TemperatureMeasurementPoint(
      id: 'sensor.antishutdown_ds18b20_temperature',
      description: 'Entrance',
      color: wongColorblindPalette[5]),
];

class TemperaturesView extends StatelessWidget {
  const TemperaturesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<TemperatureRequestCubit, TemperatureRequestState>(
        builder: (context, state) {
          return Wrap(
            children: temperatureMeasurementEntities
                .map((entity) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TemperaturesChart(
                        entity: entity,
                        averageWindow: const Duration(minutes: 5),
                        verticalAxisStep: 24 * 60 / 5, // one day
                        height: 140,
                      ),
                    ))
                .toList(growable: false),
          );
        },
      ),
    );
  }

  static TemperatureRequestCubit generateCubit(BuildContext context) {
    final endTime = DateTime.now();
    final startTime = endTime.subtract(const Duration(
        days: 2)); // Home Assistant might not have that much data!

    final entityIds = temperatureMeasurementEntities
        .map((entity) => entity.id)
        .toList(growable: false);

    return TemperatureRequestCubit()..load(startTime, endTime, entityIds);
  }
}
