import 'dart:async';

import 'package:dashboard/models/cubit/binary_sensor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BinarySensor extends StatefulWidget {
  const BinarySensor({super.key, required this.entityId, required this.builder});

  final Widget Function(BuildContext context, bool? state) builder;
  final String entityId;

  @override
  State<BinarySensor> createState() => _BinarySensorState();
}

class _BinarySensorState extends State<BinarySensor> {
  BinarySensorCubit? cubit;

  @override
  void initState() {
    super.initState();
    cubit = BinarySensorCubit(entityId: widget.entityId);
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
    return BlocBuilder<BinarySensorCubit, BinarySensorState>(
      bloc: cubit,
      builder: (context, state) {
        if (state is BinarySensorHasData) {
          return widget.builder(context, state.state);
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
