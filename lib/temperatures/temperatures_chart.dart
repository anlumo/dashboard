import 'package:dashboard/models/cubit/temperature_request_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
class TemperatureMeasurementPoint {
  final String id;
  final String description;
  final Color color;

  const TemperatureMeasurementPoint({
    required this.id,
    required this.description,
    required this.color,
  });
}

class TemperaturesChart extends StatelessWidget {
  final TemperatureMeasurementPoint entity;
  final double height;

  const TemperaturesChart({Key? key, required this.entity, this.height = 200})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemperatureRequestCubit, TemperatureRequestState>(
      builder: (context, state) {
        if (state is TemperatureRequestInitial ||
            state is TemperatureRequestLoading) {
          return SizedBox(
            height: height,
            child: Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          );
        }
        if (state is TemperatureRequestFailed) {
          return Center(
              child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).errorColor,
              ),
              Text('${state.error}',
                  style: TextStyle(color: Theme.of(context).errorColor)),
            ],
          ));
        }

        final values = (state as TemperatureRequestHasData).data[entity.id];

        print('temperatures for ${entity.id}: $values');

        return const SizedBox();
      },
    );
  }
}
