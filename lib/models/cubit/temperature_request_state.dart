part of 'temperature_request_cubit.dart';

abstract class TemperatureRequestState extends Equatable {
  const TemperatureRequestState();

  @override
  List<Object> get props => [];
}

class TemperatureRequestInitial extends TemperatureRequestState {}

class TemperatureRequestLoading extends TemperatureRequestState {}

class TemperatureRequestHasData extends TemperatureRequestState {
  final Map<String, List<TemperatureEntry>> data;

  const TemperatureRequestHasData(this.data);

  @override
  List<Object> get props => [data];
}

class TemperatureRequestFailed extends TemperatureRequestState {
  final Error error;

  const TemperatureRequestFailed(this.error);

  @override
  List<Object> get props => [error];
}
