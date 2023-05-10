import 'package:flutter/material.dart';

class TelephoneSensor extends StatelessWidget {
  const TelephoneSensor({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: SizedBox(
        width: 256,
        height: 128,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(title),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    '2',
                    style: TextStyle(fontSize: 60, color: Colors.amber),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
