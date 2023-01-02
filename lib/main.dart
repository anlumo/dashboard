import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:dashboard/tabs_view.dart';
import 'package:dashboard/utils/tuple.dart';
import 'package:flutter/material.dart';

final kColorScheme = [
  Tuple(0, Colors.grey), // other
  Tuple(2, Colors.brown), // beer
  Tuple(3, Colors.green), // Wostok
  Tuple(4, Colors.black), // Cola
  Tuple(1, Colors.yellow), // Mate
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencyInjection();
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: const MaterialColor(0xff182E46, <int, Color>{
              50: Color(0xffb3b5b8),
              100: Color(0xff3e9ac4),
              200: Color(0xff0085b3),
              300: Color(0xff007fb4),
              400: Color(0xff0070a0),
              500: Color(0xff094f73),
              600: Color(0xff334B6A),
              700: Color(0xff003960),
              800: Color(0xff1C3654),
              900: Color(0xff182E46),
            }),
            accentColor: const Color(0xffcc6427)),
      ),
      home: const Scaffold(
        backgroundColor: Color(0xff181b1f),
        body: TabsView(
          switchTime: Duration(seconds: 10),
          animationTime: Duration(seconds: 1),
        ),
      ),
    );
  }
}
