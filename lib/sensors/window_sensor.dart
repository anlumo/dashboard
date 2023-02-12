import 'package:dashboard/sensors/binary_sensor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WindowSensor extends StatelessWidget {
  const WindowSensor({super.key, required this.title, required this.entityId});

  final String title;
  final String entityId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(8), child: Text(title))),
          BinarySensor(
            entityId: entityId,
            builder: (context, state) {
              return Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: state ? const Text('offen') : const Text('zu')),
                  SvgPicture.asset(
                    state
                        ? "assets/window-open-variant.svg"
                        : "assets/window-closed-variant.svg",
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                        state ? Colors.red : Colors.green, BlendMode.srcATop),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
