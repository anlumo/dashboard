import 'package:dashboard/sensors/sensor.dart';
import 'package:flutter/material.dart';

class PowerSensor extends StatelessWidget {
  const PowerSensor(
      {super.key, required this.title, required this.entityId, this.color});

  final String title;
  final String entityId;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: color,
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
                      final value = double.parse(state) * 1000;
                      return Text(
                        '${value.round()} W',
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
