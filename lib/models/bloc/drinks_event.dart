part of 'drinks_bloc.dart';

abstract class DrinksEvent extends Equatable {
  const DrinksEvent();

  @override
  List<Object> get props => [];
}

class DrinksLoading extends DrinksEvent {
  const DrinksLoading();
}

class DrinksGotData extends DrinksEvent {
  const DrinksGotData({required this.data});
  final List<Map<String, Map<String, dynamic>>> data;
}

class DrinksFailed extends DrinksEvent {
  const DrinksFailed({required this.error});
  final dynamic error;
}
