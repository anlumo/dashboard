import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dashboard/modules/config/config.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'drinks_request_state.dart';

class DrinksRequestCubit extends Cubit<DrinksRequestState> {
  DrinksRequestCubit() : super(DrinksRequestInitial());

  Future<void> load() async {
    if (state is DrinksRequestInitial) {
      // keep old data while reloading
      emit(DrinksRequestLoading());
    }
    final config = await getIt.getAsync<Config>();
    final host = config.data['drinks']['address'];
    try {
      final [history, rankings] = await Future.wait([
        http.get(Uri.http(host, "/drinks/history")),
        http.get(Uri.http(host, "/drinks/rankings")),
      ]);
      final historyDecoded = jsonDecode(utf8.decode(history.bodyBytes)).cast<Map<String, dynamic>>();
      final rankingsDecoded = Ranking.fromJson(jsonDecode(utf8.decode(rankings.bodyBytes)).cast());

      emit(DrinksRequestHasData(history: historyDecoded, rankings: rankingsDecoded));
    } on Error catch (error) {
      emit(DrinksRequestFailed(error));
    }
  }
}
