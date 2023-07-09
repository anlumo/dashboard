part of 'drinks_request_cubit.dart';

sealed class DrinksRequestState extends Equatable {
  const DrinksRequestState();

  @override
  List<Object> get props => [];
}

final class DrinksRequestInitial extends DrinksRequestState {}

final class DrinksRequestLoading extends DrinksRequestState {}

final class RankingEntry {
  final String name;
  final int total;
  final int category;

  const RankingEntry(this.name, this.total, this.category);

  factory RankingEntry.fromJson(Map<String, dynamic> json) =>
      RankingEntry(json['name'], json['total'] as int, json['category'] as int);
}

final class RankingCategory {
  final int category;
  final List<RankingEntry> entries;

  const RankingCategory(this.category, this.entries);

  factory RankingCategory.fromJson(Map<String, dynamic> json) => RankingCategory(json['category'] as int,
      (json['entries'].map<RankingEntry>((entry) => RankingEntry.fromJson(entry))).toList(growable: false));
}

final class Ranking {
  final List<RankingCategory> categories;

  const Ranking(this.categories);

  factory Ranking.fromJson(List<dynamic> json) =>
      Ranking(json.map((cat) => RankingCategory.fromJson(cat)).toList(growable: false));
}

final class DrinksRequestHasData extends DrinksRequestState {
  final List<Map<String, dynamic>> history;
  final Ranking rankings;

  const DrinksRequestHasData({required this.history, required this.rankings});

  RankingCategory top10InCategory(int category) => rankings.categories[category];

  @override
  List<Object> get props => [history, rankings];
}

final class DrinksRequestFailed extends DrinksRequestState {
  final Error error;

  const DrinksRequestFailed(this.error);

  @override
  List<Object> get props => [error];
}
