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
      id: 'sensor.hmtemp_temperature',
      description: 'Heavy Machinery',
      color: wongColorblindPalette[2]),
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
                .map((entity) => TemperaturesChart(entity: entity))
                .toList(growable: false),
          );
        },
      ),
    );
  }

  static TemperatureRequestCubit generateCubit(BuildContext context) {
    final endTime = DateTime.now();
    final startTime = endTime.subtract(const Duration(
        days: 14)); // Home Assistant might not have that much data!

    final entityIds = temperatureMeasurementEntities
        .map((entity) => entity.id)
        .toList(growable: false);

    return TemperatureRequestCubit()..load(startTime, endTime, entityIds);
  }
}
