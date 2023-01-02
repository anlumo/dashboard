import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:dashboard/modules/postgres/database.dart';
import 'package:equatable/equatable.dart';

part 'drinks_event.dart';
part 'drinks_state.dart';

class DrinksBloc extends Bloc<DrinksEvent, DrinksState> {
  DrinksBloc() : super(const DrinksInitial()) {
    on<DrinksEvent>((event, emit) {
      if (event is DrinksGotData) {
        emit(DrinksHasData(event.data));
      } else if (event is DrinksFailed) {
        emit(DrinksError(event.error));
      }
    });
  }

  StreamSubscription? _timerSubscription;

  void _tick(String sql, Map<String, dynamic>? variables) async {
    if (!isClosed) {
      try {
        final database = await getIt.getAsync<Database>();
        final data = await database.query(sql, variables: variables);
        add(DrinksGotData(data: data));
      } catch (e) {
        print("Fetching drinks failed: $e");
        add(DrinksFailed(error: e));
      }
    }
  }

  void startTimer(Duration period, String sql,
      {Map<String, dynamic>? variables}) {
    if (_timerSubscription == null) {
      _timerSubscription = Stream.periodic(period, (_) => {}).listen(
        (_) => _tick(sql, variables),
      );
      _finalizer.attach(this, _timerSubscription!, detach: this);
    }
  }

  void stopTimer() {
    if (_timerSubscription != null) {
      _timerSubscription!.cancel();
      _finalizer.detach(this);
      _timerSubscription = null;
    }
  }

  static final Finalizer<StreamSubscription> _finalizer =
      Finalizer((subscription) => subscription.cancel());

  void dispose() {
    _timerSubscription?.cancel();
  }
}
