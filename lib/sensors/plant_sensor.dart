import 'package:dashboard/sensors/sensor.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlantSensor extends StatelessWidget {
  const PlantSensor({super.key, required this.title, required this.entityId});

  final String title;
  final String entityId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: SizedBox(
        width: 256,
        height: 256,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
        ),
      ),
    );
  }
}
