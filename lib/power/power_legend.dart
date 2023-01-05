import 'package:dashboard/power/power_chart.dart';
import 'package:flutter/material.dart';

class PowerLegend extends StatelessWidget {
  final List<PowerMeasurementPoint> entities;
  final TextStyle? textStyle;
  final Size colorSize;

  const PowerLegend(
      {Key? key,
      required this.entities,
      required this.textStyle,
      required this.colorSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entityOrder = entities
        .expand((element) => element.depthFirstIterator())
        .toList(growable: false)
        .reversed;

    return Column(
      children: entityOrder
          .map((entity) => Row(
                children: [
                  SizedBox(
                      width: colorSize.width,
                      height: colorSize.height,
                      child: ColoredBox(color: entity.color)),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(entity.description, style: textStyle),
                  ),
                ],
              ))
          .toList(growable: false),
    );
  }
}
