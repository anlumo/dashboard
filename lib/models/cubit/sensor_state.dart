part of 'sensor_cubit.dart';

abstract class SensorState extends Equatable {
  const SensorState();

  @override
  List<Object> get props => [];
}

class SensorInitial extends SensorState {}

class SensorLoading extends SensorState {}

class SensorHasData extends SensorState {
  final String state;

  const SensorHasData(this.state);

  @override
  List<Object> get props => [state];
}

class SensorFailed extends SensorState {
  final Error error;

  const SensorFailed(this.error);

  @override
  List<Object> get props => [error];
}
