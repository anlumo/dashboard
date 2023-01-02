import 'package:dashboard/models/bloc/hass_bloc.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:dashboard/utils/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PowerChart extends StatelessWidget {
  final String entityId;

  const PowerChart({Key? key, required this.entityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hassBloc = getIt.get<HassBloc>();
    hassBloc.add(const HassConnect());

    return BlocBuilder<HassBloc, HassState>(
      bloc: hassBloc,
      builder: (context, state) {
        if (state is HassInitial || state is HassConnecting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary)),
            ],
          );
        }
        if (state is HassDisconnected) {
          return const Center(
              child: Icon(
            Icons.error_outline,
            color: Colors.red,
          ));
        }
        // only remaining option is connected state
        final hass = (state as HassConnected).hass;

        final endTime = DateTime.now();
        final startTime = endTime.subtract(const Duration(days: 30));

        return FutureBuilder(
          future: hass.request("history/history_during_period", data: {
            "start_time": startTime.toIso8601String(),
            "end_time": endTime.toIso8601String(),
            "significant_changes_only": false,
            "include_start_time_state": true,
            "minimal_response": true,
            "no_attributes": true,
            "entity_ids": [
              entityId,
            ],
          }),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }
            if (!snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary)),
                ],
              );
            }
            final data = snapshot.data as Map<String, dynamic>;
            if (!data['success']) {
              return const Center(
                  child: Icon(
                Icons.error_outline,
                color: Colors.red,
              ));
            }
            final result = (data['result'] as Map<String, dynamic>)[entityId]
                as List<dynamic>;

            final values = result.map((event) {
              try {
                final s =
                    double.parse((event as Map<String, dynamic>)['s']); // kWh
                final lu = DateTime.fromMicrosecondsSinceEpoch(
                    ((event['lu'] as double) * 1e6).round());
                return Tuple(lu, s);
              } catch (_) {
                return null;
              }
            }).toList();
            print('values = $values');

            return const SizedBox();
          },
        );
      },
    );
  }
}
