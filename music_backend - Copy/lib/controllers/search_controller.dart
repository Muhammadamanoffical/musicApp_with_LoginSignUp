import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../db.dart';

class SearchController {
  static Future<Response> searchSongs(Request req) async {
    try {
      final conn = await connectDB();
      final query = req.url.queryParameters['q'] ?? '';

      var results = await conn.query(
        "SELECT * FROM songs WHERE title LIKE ?",
        ['%$query%'],
      );

      final list = results.map((r) {
        return {
          "id": r[0],
          "title": r[1],
          "artist": r[2],
          "url": r[3],
          "cover": r[4],
        };
      }).toList();

      await conn.close();

      return Response.ok(jsonEncode(list));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}