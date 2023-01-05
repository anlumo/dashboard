import 'dart:async';

import 'package:dashboard/drinks/drinks_view.dart';
import 'package:dashboard/models/cubit/drinks_request_cubit.dart';
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

    views.add(const DrinksView(key: ValueKey<int>(0)));
    views.add(const PowerView(key: ValueKey<int>(1)));

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
        const BlocProvider(create: PowerView.generateCubit),
        BlocProvider(create: (_) => DrinksRequestCubit()..load()),
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
        child: views[index],
      ),
    );
  }
}
