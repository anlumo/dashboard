part of 'hass_bloc.dart';

sealed class HassState extends Equatable {
  const HassState();

  @override
  List<Object> get props => [];
}

final class HassInitial extends HassState {}

final class HassConnecting extends HassState {}

final class HassConnected extends HassState {
  final Hass hass;

  const HassConnected(this.hass);

  @override
  List<Object> get props => [hass];
}

final class HassDisconnected extends HassState {}
