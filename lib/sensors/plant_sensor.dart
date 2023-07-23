import 'package:dashboard/sensors/sensor.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlantSensor extends StatelessWidget {
  const PlantSensor({super.key, required this.title, required this.entityId, required this.batteryId});

  final String title;
  final String entityId;
  final String batteryId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: SizedBox(
        width: 256,
        height: 256,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(title),
                  ),
                  Expanded(
                    child: Sensor(
                      entityId: entityId,
                      builder: (context, state) {
                        final value = double.tryParse(state);
                        final color = value != null && value > 60
                            ? Colors.green
                            : value != null && value > 20
                                ? Colors.yellow
                                : value != null
                                    ? Colors.red
                                    : Colors.grey;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Icon(
                                FontAwesomeIcons.seedling,
                                color: color,
                                size: 100,
                              ),
                            ),
                            DecoratedBox(
                              decoration: const ShapeDecoration(shape: StadiumBorder(), color: Colors.grey),
                              child: SizedBox(
                                width: 20,
                                height: 128,
                                child: value == null
                                    ? null
                                    : Align(
                                        alignment: Alignment.bottomCenter,
                                        child: DecoratedBox(
                                          decoration: ShapeDecoration(shape: const StadiumBorder(), color: color),
                                          child: SizedBox(
                                            width: 20,
                                            height: 128 * value / 100,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Sensor(
                    entityId: batteryId,
                    builder: (context, state) {
                      final value = double.tryParse(state);
                      if (value == null) {
                        return const SizedBox();
                      }

                      return Icon(
                          switch (value) {
                            >= 90 => FontAwesomeIcons.batteryFull,
                            >= 75 => FontAwesomeIcons.batteryThreeQuarters,
                            >= 50 => FontAwesomeIcons.batteryHalf,
                            >= 25 => FontAwesomeIcons.batteryQuarter,
                            _ => FontAwesomeIcons.batteryEmpty,
                          },
                          color: switch (value) {
                            >= 90 => Colors.green,
                            >= 75 => Colors.yellow,
                            >= 50 => Colors.amber,
                            >= 25 => Colors.orange,
                            _ => Colors.red,
                          });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
