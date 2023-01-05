import 'package:bloc/bloc.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:dashboard/modules/postgres/database.dart';
import 'package:equatable/equatable.dart';

part 'drinks_request_state.dart';

class DrinksRequestCubit extends Cubit<DrinksRequestState> {
  DrinksRequestCubit() : super(DrinksRequestInitial());

  Future<void> load() async {
    if (state is DrinksRequestInitial) {
      // keep old data while reloading
      emit(DrinksRequestLoading());
    }
    final database = await getIt.getAsync<Database>();

    try {
      final historyDataFuture = database.query('''SELECT date, category, count
      FROM drinks, eancodes
      WHERE
        date BETWEEN (NOW() - interval '30 days') AND NOW()
        AND drinks.ean = eancodes.id''');

      final top10DataFutures = Iterable.generate(5, (category) {
        return database.query('''SELECT
              name,
              SUM(count) AS total,
              category
            FROM drinks, eancodes
            WHERE drinks.date >= (CURRENT_DATE - INTERVAL '1 month')
              AND drinks.ean=eancodes.id
              ${category == 0 ? '' : 'AND category = $category'}
            GROUP BY drinks.ean,eancodes.name, eancodes.category
            ORDER BY total DESC LIMIT 10''');
      });

      final results =
          await Future.wait([historyDataFuture].followedBy(top10DataFutures));

      emit(DrinksRequestHasData(results));
    } on Error catch (error) {
      emit(DrinksRequestFailed(error));
    }
  }
}
