part of 'drinks_bloc.dart';

abstract class DrinksState extends Equatable {
  const DrinksState();

  @override
  List<Object> get props => [];
}

class DrinksInitial extends DrinksState {
  const DrinksInitial();

  @override
  String toString() => 'DrinksInitial {}';
}

class DrinksHasData extends DrinksState {
  const DrinksHasData(this.drinks);
  final List<Map<String, Map<String, dynamic>>> drinks;

  @override
  String toString() => 'DrinksHasData { drinks: $drinks }';

  @override
  List<Object> get props => [drinks];
}

class DrinksError extends DrinksState {
  const DrinksError(this.error);
  final dynamic error;

  @override
  String toString() => 'DrinksError { error: $error }';

  @override
  List<Object> get props => [error];
}
