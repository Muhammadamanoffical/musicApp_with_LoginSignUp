import 'package:mysql1/mysql1.dart';

Future<MySqlConnection> connectDB() async {
  final settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'dart_user',
    password: '123456',
    db: 'testing',
  );

  return await MySqlConnection.connect(settings);
}