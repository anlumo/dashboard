import 'package:dashboard/sensors/binary_sensor.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ToiletSensor extends StatelessWidget {
  const ToiletSensor({super.key, required this.title, required this.entityId});

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
                child: Center(
                  child: BinarySensor(
                    entityId: entityId,
                    builder: (context, state) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Icon(
                              FontAwesomeIcons.toilet,
                              color: state ? Colors.green : Colors.red,
                              size: 100,
                            ),
                          ),
                          Positioned(
                              right: 0,
                              bottom: 0,
                              child: Icon(
                                  state
                                      ? FontAwesomeIcons.unlockKeyhole
                                      : FontAwesomeIcons.lock,
                                  size: 70)),
                        ],
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
