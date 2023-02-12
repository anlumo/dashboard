part of 'binary_sensor_cubit.dart';

abstract class BinarySensorState extends Equatable {
  const BinarySensorState();

  @override
  List<Object> get props => [];
}

class BinarySensorInitial extends BinarySensorState {}

class BinarySensorLoading extends BinarySensorState {}

class BinarySensorHasData extends BinarySensorState {
  final bool state;

  const BinarySensorHasData(this.state);

  @override
  List<Object> get props => [state];
}

class BinarySensorFailed extends BinarySensorState {
  final Error error;

  const BinarySensorFailed(this.error);

  @override
  List<Object> get props => [error];
}
