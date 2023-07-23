import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dashboard/models/bloc/hass_bloc.dart';
import 'package:dashboard/models/hass.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:equatable/equatable.dart';

part 'binary_sensor_state.dart';

class BinarySensorCubit extends Cubit<BinarySensorState> {
  BinarySensorCubit({required this.entityId}) : super(BinarySensorInitial());

  final String entityId;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  Future<void> close() async {
    _subscription?.cancel();
    super.close();
  }

  Future<void> subscribe() async {
    if (_subscription != null) {
      return;
    }
    Hass? hass;
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

    try {
      _subscription = hass.subscribeTrigger({
        "platform": "state",
        "entity_id": entityId,
      }).listen(_stateChangedEvent);
      emit(BinarySensorLoading());

      final initialState = await hass.request('get_states');
      try {
        final state = (initialState['result'] as List<dynamic>).firstWhere((entity) => entity['entity_id'] == entityId);
        print('new state $entityId: $state');
        if (state['state'] == 'on' || state['state'] == 'off') {
          emit(BinarySensorHasData(state['state'] == 'on'));
        } else if (state['state'] == 'unavailable') {
          emit(const BinarySensorHasData(null));
        }
      } catch (_) {
        // entity not found
      }
    } catch (e) {
      emit(BinarySensorFailed(e as Error));
    }
  }

  void unsubscribe() {
    if (_subscription != null) {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  void _stateChangedEvent(Map<String, dynamic> event) {
    final state =
        event['variables']?['trigger']?['to_state'] != null ? event['variables']['trigger']['to_state']['state'] : null;
    print('new state $entityId: $event');
    switch (state) {
      case null:
        emit(BinarySensorLoading());
      case 'on':
        emit(const BinarySensorHasData(true));
      case 'off':
        emit(const BinarySensorHasData(false));
      case 'unavailable':
        emit(const BinarySensorHasData(null));
    }
  }
}
