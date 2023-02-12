import 'package:dashboard/sensors/toilet_sensor.dart';
import 'package:dashboard/sensors/window_sensor.dart';
import 'package:flutter/material.dart';

class SensorsView extends StatelessWidget {
  const SensorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const ToiletSensor(
            title: "Sitzklo",
            entityId: "binary_sensor.switch1",
          ),
          const ToiletSensor(
            title: "Stehklo",
            entityId: "binary_sensor.switch2",
          ),
          Card(
            elevation: 10,
            child: SizedBox(
              width: 256,
              child: Column(
                children: const [
                  WindowSensor(
                    title: "Otterspace 5",
                    entityId: "binary_sensor.otterwindow5_contact",
                  ),
                  WindowSensor(
                    title: "Kitchen",
                    entityId: "binary_sensor.kitchenwindow_contact",
                  ),
                  WindowSensor(
                    title: "Toilet",
                    entityId: "binary_sensor.toiletwindow_contact",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
