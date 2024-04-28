import 'package:dashboard/sensors/sensor.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

class AQISensor extends StatelessWidget {
  const AQISensor({super.key, required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: SizedBox(
        width: 256,
        height: 120,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Sensor(
              entityId: entityId,
              builder: (context, state) {
                final value = double.parse(state);
                return AnimatedRadialGauge(
                  duration: const Duration(seconds: 1),
                  radius: 100,
                  value: value,
                  axis: GaugeAxis(
                    min: value <= 150 ? 0 : 150,
                    max: value <= 150 ? 150 : 400,
                    pointer: const GaugePointer.needle(
                      width: 10,
                      height: 60,
                      color: Color(0xffeeeeee),
                      position: GaugePointerPosition.surface(offset: Offset(0, 10)),
                    ),
                    style: const GaugeAxisStyle(background: null),
                    progressBar: null,
                    segments: value <= 150
                        ? [
                            const GaugeSegment(
                              from: 0,
                              to: 50,
                              color: Colors.green,
                            ),
                            const GaugeSegment(
                              from: 50,
                              to: 100,
                              color: Colors.yellow,
                            ),
                            const GaugeSegment(
                              from: 100,
                              to: 150,
                              color: Colors.orange,
                            ),
                          ]
                        : [
                            GaugeSegment(
                              from: 150,
                              to: 200,
                              color: Colors.redAccent[700]!,
                            ),
                            const GaugeSegment(
                              from: 200,
                              to: 300,
                              color: Color(0xff800000),
                            ),
                            GaugeSegment(
                              from: 300,
                              to: 400,
                              color: Colors.brown[900]!,
                            ),
                          ],
                  ),
                  builder: (context, child, value) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'AQI ${value.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.amber, fontSize: 30),
                        maxLines: 1,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
