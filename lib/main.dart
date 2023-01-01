import 'package:dashboard/drinks_history.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:flutter/material.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await configureDependencyInjection();
  print("Startup!");
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
      home: Scaffold(
        backgroundColor: const Color(0xff181b1f),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DrinksHistory(),
            ),
          ],
        ),
      ),
    );
  }
}
