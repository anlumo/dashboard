import 'package:bloc/bloc.dart';
import 'package:dashboard/models/bloc/hass_bloc.dart';
import 'package:dashboard/models/hass.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:equatable/equatable.dart';

part 'power_request_state.dart';

class PowerRequestCubit extends Cubit<PowerRequestState> {
  PowerRequestCubit() : super(PowerRequestInitial());

  // can be called multiple times to reload the data
  Future<void> load(
      DateTime start, DateTime end, List<String> entityIds) async {
    Hass? hass;
    print('power load $start to $end');
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
    if (state is PowerRequestInitial) {
      // avoid setting this state if we still have old data
      emit(PowerRequestLoading());
    }
    try {
      final result = await hass.request("history/history_during_period", data: {
        "start_time": start.toIso8601String(),
        "end_time": end.toIso8601String(),
        "significant_changes_only": false,
        "include_start_time_state": true,
        "minimal_response": true,
        "no_attributes": true,
        "entity_ids": entityIds,
      });
      emit(PowerRequestHasData(result));
    } on Error catch (error) {
      emit(PowerRequestFailed(error));
    }
  }
}
