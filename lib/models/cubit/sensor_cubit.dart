import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dashboard/models/bloc/hass_bloc.dart';
import 'package:dashboard/models/hass.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:equatable/equatable.dart';

part 'sensor_state.dart';

class SensorCubit extends Cubit<SensorState> {
  SensorCubit({required this.entityId}) : super(SensorInitial());

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
      emit(SensorLoading());

      final initialState = await hass.request('get_states');
      try {
        final state = (initialState['result'] as List<dynamic>)
            .firstWhere((entity) => entity['entity_id'] == entityId);
        emit(SensorHasData(state['state']));
      } catch (_) {
        // entity not found
      }
    } catch (e) {
      emit(SensorFailed(e as Error));
    }
  }

  void unsubscribe() {
    if (_subscription != null) {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  void _stateChangedEvent(Map<String, dynamic> event) {
    final state = event['variables']?['trigger']?['to_state']?['state'];
    emit(state != null ? SensorHasData(state) : SensorLoading());
  }
}
