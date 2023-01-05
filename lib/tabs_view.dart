import 'dart:async';

import 'package:dashboard/drinks/drinks_view.dart';
import 'package:dashboard/models/cubit/power_request_cubit.dart';
import 'package:dashboard/power/power_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabsView extends StatefulWidget {
  final Duration switchTime;
  final Duration animationTime;
  const TabsView({
    Key? key,
    required this.switchTime,
    required this.animationTime,
  }) : super(key: key);

  @override
  State<TabsView> createState() => _TabsViewState();
}

class _TabsViewState extends State<TabsView> {
  Timer? tabSwitchTimer;
  int index = 0;
  List<Widget> views = [];

  @override
  void initState() {
    super.initState();

    views.add(const DrinksView());
    views.add(const PowerView());

    tabSwitchTimer = Timer.periodic(widget.switchTime, (timer) {
      setState(() {
        index = (index + 1) % views.length;
      });
    });
  }

  @override
  void dispose() {
    tabSwitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) {
          final endTime = DateTime.now();
          final startTime = endTime.subtract(const Duration(
              days: 14)); // Home Assistant might not have that much data!

          final entityIds = powerMeasurementEntities
              .expand((entity) => entity.iterator())
              .map((entity) => entity.id)
              .toList(growable: false);

          return PowerRequestCubit()..load(startTime, endTime, entityIds);
        }),
      ],
      child: AnimatedSwitcher(
        duration: widget.animationTime,
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
                  begin: (animation.isCompleted)
                      ? const Offset(-1, 0)
                      : const Offset(1, 0),
                  end: const Offset(0, 0))
              .animate(animation),
          child: child,
        ),
        child: IndexedStack(
          key: ValueKey<int>(index),
          index: index,
          children: views,
        ),
      ),
    );
  }
}
