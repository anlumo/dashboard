part of 'drinks_request_cubit.dart';

abstract class DrinksRequestState extends Equatable {
  const DrinksRequestState();

  @override
  List<Object> get props => [];
}

class DrinksRequestInitial extends DrinksRequestState {}

class DrinksRequestLoading extends DrinksRequestState {}

class DrinksRequestHasData extends DrinksRequestState {
  final List<List<Map<String, Map<String, dynamic>>>> data;

  const DrinksRequestHasData(this.data);

  List<Map<String, Map<String, dynamic>>> get history => data[0];
  List<Map<String, Map<String, dynamic>>> top10InCategory(int category) =>
      data[category + 1];

  @override
  List<Object> get props => [data];
}

class DrinksRequestFailed extends DrinksRequestState {
  final Error error;

  const DrinksRequestFailed(this.error);

  @override
  List<Object> get props => [error];
}
