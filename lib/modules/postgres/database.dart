import 'package:dashboard/modules/config/config.dart';
import 'package:injectable/injectable.dart';
import 'package:postgres/postgres.dart';

@lazySingleton
class Database {
  @factoryMethod
  static Future<Database> create(Config config) async {
    final dbconfig = config.data['postgres'];
    final connection = PostgreSQLConnection(
      dbconfig['address'],
      dbconfig['port'],
      dbconfig['database'],
      username: dbconfig['username'],
      password: dbconfig['password'],
    );
    try {
      print("Trying to connect to database...");
      await connection.open();
      print("Connected to database!");
    } catch (e) {
      print("Database connection failed: $e");
    }

    return Database._(connection: connection);
  }

  Database._({required PostgreSQLConnection connection})
      : _connection = connection;

  final PostgreSQLConnection _connection;

  Future<List<Map<String, Map<String, dynamic>>>> query(String sql,
      {Map<String, dynamic>? variables}) async {
    return await _connection.mappedResultsQuery(sql,
        substitutionValues: variables);
  }

  Future<T> transaction<T>(
      Future<T> Function(PostgreSQLExecutionContext) txn) async {
    return await _connection.transaction(txn);
  }
}
