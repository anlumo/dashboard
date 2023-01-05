import 'dart:async';

import 'package:dashboard/drinks/drinks_view.dart';
import 'package:dashboard/power/power_view.dart';
import 'package:flutter/material.dart';

class TabsView extends StatefulWidget {
  final Duration switchTime;
  final Duration animationTime;
  const TabsView(
      {Key? key, required this.switchTime, required this.animationTime})
      : super(key: key);

  @override
  State<TabsView> createState() => _TabsViewState();
}

class _TabsViewState extends State<TabsView> {
  Timer? tabSwitchTimer;
  int currentView = 0;
  List<Widget> views = [];

  @override
  void initState() {
    super.initState();

    views.add(const DrinksView(key: Key("0")));
    views.add(const PowerView(key: Key("1")));

    tabSwitchTimer = Timer.periodic(widget.switchTime, (timer) {
      setState(() {
        currentView = (currentView + 1) % views.length;
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
    return AnimatedSwitcher(
      duration: widget.animationTime,
      transitionBuilder: (child, animation) {
        return SlideTransition(
            position: Tween<Offset>(
                    begin: (animation.isCompleted)
                        ? const Offset(-1, 0)
                        : const Offset(1, 0),
                    end: const Offset(0, 0))
                .animate(animation),
            child: child);
      },
      child: views[currentView],
    );
  }
}
