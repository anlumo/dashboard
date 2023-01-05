part of 'power_request_cubit.dart';

abstract class PowerRequestState extends Equatable {
  const PowerRequestState();

  @override
  List<Object> get props => [];
}

class PowerRequestInitial extends PowerRequestState {}

class PowerRequestLoading extends PowerRequestState {}

class PowerRequestHasData extends PowerRequestState {
  final Map<String, dynamic> data;

  const PowerRequestHasData(this.data);

  @override
  List<Object> get props => [data];
}

class PowerRequestFailed extends PowerRequestState {
  final Error error;

  const PowerRequestFailed(this.error);

  @override
  List<Object> get props => [error];
}
