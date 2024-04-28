import 'package:dashboard/sensors/aqi_sensor.dart';
import 'package:dashboard/sensors/co2_sensor.dart';
import 'package:dashboard/sensors/plant_sensor.dart';
import 'package:dashboard/sensors/telephone_sensor.dart';
import 'package:dashboard/sensors/temperature_sensor.dart';
import 'package:dashboard/sensors/toilet_sensor.dart';
import 'package:dashboard/sensors/window_sensor.dart';
import 'package:flutter/material.dart';

class SensorsView extends StatelessWidget {
  const SensorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToiletSensor(
            title: "Stehklo",
            entityId: "binary_sensor.switch2",
          ),
          ToiletSensor(
            title: "Sitzklo",
            entityId: "binary_sensor.switch1",
          ),
          Card(
            elevation: 5,
            child: SizedBox(
              width: 256,
              height: 256,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                  WindowSensor(
                    title: "Bibliothek",
                    entityId: "binary_sensor.librarywindow_contact",
                  ),
                  WindowSensor(
                    title: "WEL",
                    entityId: "binary_sensor.welwindow_contact",
                  ),
                  WindowSensor(
                    title: "HEL",
                    entityId: "binary_sensor.helwindow_contact",
                  ),
                  WindowSensor(
                    title: "Lasercutter",
                    entityId: "binary_sensor.lasercutterwindow_contact",
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 280,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TemperatureSensor(
                  title: "Otterspace",
                  entityId: "sensor.ag_one_temperature",
                ),
                Co2Sensor(
                  title: "Otterspace CO₂",
                  entityId: "sensor.ag_one_co2",
                ),
              ],
            ),
          ),
          SizedBox(
              height: 280,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AQISensor(
                  entityId: "sensor.ag_one_pm_2_5_aqi",
                ),
                TelephoneSensor(title: "Telefonzellen"),
              ])),
          PlantSensor(
            title: "MetaPlant",
            entityId: "sensor.metaplant_soil",
            batteryId: "sensor.metaplant_battery",
          ),
        ],
      ),
    );
  }
}
