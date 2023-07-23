import 'package:bloc/bloc.dart';
import 'package:dashboard/models/bloc/hass_bloc.dart';
import 'package:dashboard/models/hass.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'temperature_request_state.dart';

@immutable
class TemperatureEntry {
  final DateTime time;
  final double temperature;

  const TemperatureEntry(this.time, this.temperature);

  @override
  String toString() => 'TemperatureEntry($time, $temperature)';
}

class TemperatureRequestCubit extends Cubit<TemperatureRequestState> {
  final Set<String> _entityIds = {};
  Duration? dataDuration;
  TemperatureRequestCubit() : super(TemperatureRequestInitial());

  // can be called multiple times to reload the data
  Future<void> load(DateTime start, DateTime end, List<String> entityIds) async {
    Hass? hass;
    print('temperature load $start to $end');
    dataDuration = end.difference(start);
    final hassBloc = getIt.get<HassBloc>();
    if (hassBloc.state is HassConnected) {
      hass = (hassBloc.state as HassConnected).hass;
    } else {
      hassBloc.add(const HassConnect());
      await for (final hassState in hassBloc.stream) {
        if (hassState is HassConnected) {
          hass = hassState.hass;
          break;
        }
      }
    }
    if (hass == null) {
      return;
    }
    _entityIds.addAll(entityIds);
    hass.stateChangedStream.listen(_stateChangedEvent);
    if (state is TemperatureRequestInitial) {
      // avoid setting this state if we still have old data
      emit(TemperatureRequestLoading());
    }
    try {
      final response = await hass.request("history/history_during_period", data: {
        "start_time": start.toIso8601String(),
        "end_time": end.toIso8601String(),
        "significant_changes_only": false,
        "include_start_time_state": true,
        "minimal_response": true,
        "no_attributes": true,
        "entity_ids": entityIds,
      });
      if (response['success']) {
        emit(
          TemperatureRequestHasData(
            Map.fromEntries(
              (response['result'] as Map<String, dynamic>).entries.map(
                    (kv) => MapEntry(
                      kv.key,
                      kv.value
                          .map<TemperatureEntry?>((event) {
                            try {
                              return TemperatureEntry(
                                  DateTime.fromMicrosecondsSinceEpoch(((event['lu'] as double) * 1e6).round())
                                      .toLocal(),
                                  double.parse(event['s']));
                            } catch (_) {
                              return null;
                            }
                          })
                          .whereType<TemperatureEntry>()
                          .toList(growable: false),
                    ),
                  ),
            ),
          ),
        );
      } else {
        emit(TemperatureRequestFailed(Error()));
      }
    } on Error catch (error) {
      print('error: $error');
      emit(TemperatureRequestFailed(error));
      rethrow;
    }
  }

  void _stateChangedEvent(Map<String, dynamic> event) {
    final newState = event['data']['new_state'];
    final entityId = newState['entity_id'];
    if (_entityIds.contains(entityId) && state is TemperatureRequestHasData) {
      late final TemperatureEntry eventData;
      try {
        eventData = TemperatureEntry(DateTime.parse(newState['last_changed']), double.parse(newState['state']));
      } catch (error) {
        print('Failed parsing entry: $newState: $error');
        return;
      }
      final oldData = (state as TemperatureRequestHasData).data;
      final data = Map<String, List<TemperatureEntry>>.fromEntries(oldData.entries.map(
        (kv) {
          if (kv.key == entityId && kv.value.last.time.isBefore(eventData.time)) {
            final earliest = dataDuration != null ? eventData.time.subtract(dataDuration!) : null;
            return MapEntry(
                kv.key,
                List.unmodifiable(kv.value
                    .where((event) => earliest == null || eventData.time.isAfter(earliest))
                    .followedBy([eventData])));
          } else {
            return kv;
          }
        },
      ));
      emit(TemperatureRequestHasData(data));
    }
  }
}
