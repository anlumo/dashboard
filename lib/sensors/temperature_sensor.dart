import 'package:dashboard/sensors/sensor.dart';
import 'package:flutter/material.dart';

class TemperatureSensor extends StatelessWidget {
  const TemperatureSensor(
      {super.key, required this.title, required this.entityId});

  final String title;
  final String entityId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: SizedBox(
        width: 256,
        height: 128,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(title),
              ),
              Expanded(
                child: Center(
                  child: Sensor(
                    entityId: entityId,
                    builder: (context, state) {
                      final value = double.parse(state);
                      return Text(
                        '${value.toStringAsFixed(1)} °C',
                        style:
                            const TextStyle(fontSize: 60, color: Colors.amber),
                      );
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
