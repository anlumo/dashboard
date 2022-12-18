import 'dart:core';

class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple(
    this.item1,
    this.item2,
  );

  factory Tuple.fromJson(Map<String, dynamic> json) {
    return Tuple(
      json['item1'],
      json['item2'],
    );
  }
}
