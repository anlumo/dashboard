part of 'hass_bloc.dart';

abstract class HassState extends Equatable {
  const HassState();

  @override
  List<Object> get props => [];
}

class HassInitial extends HassState {}

class HassConnecting extends HassState {}

class HassConnected extends HassState {
  final Hass hass;

  const HassConnected(this.hass);

  @override
  List<Object> get props => [hass];
}

class HassDisconnected extends HassState {}
