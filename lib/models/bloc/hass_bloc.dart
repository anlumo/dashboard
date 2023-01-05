import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dashboard/models/hass.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'hass_event.dart';
part 'hass_state.dart';

class InvalidStateError extends Error {}

class CanceledError extends Error {}

@lazySingleton
class HassBloc extends Bloc<HassEvent, HassState> {
  HassBloc() : super(HassInitial()) {
    print('starting HassBloc');
    on<HassEvent>((event, emit) {
      if (event is HassConnect) {
        if (state is HassInitial || state is HassDisconnected) {
          Hass.connect();
        }
      } else if (event is HassStartConnecting) {
        emit(HassConnecting());
      } else if (event is HassConnectionOpen) {
        emit(HassConnected(event.hass));
      } else if (event is HassConnectionClosed) {
        if (state is HassConnected) {
          (state as HassConnected).hass.close();
        }
        emit(HassDisconnected());
      } else if (event is HassConnectionError) {
        print('Websocket connection error: ${event.error}');
        if (state is HassConnected) {
          (state as HassConnected).hass.close();
        }
        emit(HassDisconnected());
      }
    });
  }

  @override
  Future<void> close() async {
    if (state is HassConnected) {
      await (state as HassConnected).hass.close();
    }
    return super.close();
  }
}
