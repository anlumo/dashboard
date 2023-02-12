import 'dart:async';

import 'package:dashboard/models/cubit/sensor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sensor extends StatefulWidget {
  const Sensor({super.key, required this.entityId, required this.builder});

  final Widget Function(BuildContext context, String state) builder;
  final String entityId;

  @override
  State<Sensor> createState() => _SensorState();
}

class _SensorState extends State<Sensor> {
  SensorCubit? cubit;

  @override
  void initState() {
    super.initState();
    cubit = SensorCubit(entityId: widget.entityId);
    unawaited(cubit!.subscribe());
  }

  @override
  void activate() {
    super.activate();
    unawaited(cubit?.subscribe());
  }

  @override
  void deactivate() {
    cubit?.unsubscribe();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCubit, SensorState>(
      bloc: cubit,
      builder: (context, state) {
        if (state is SensorHasData) {
          return widget.builder(context, state.state);
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
