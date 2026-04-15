import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../db.dart';

class FavoriteController {
  static Future<Response> addFavorite(Request req) async {
    try {
      final conn = await connectDB();
      final body = await req.readAsString();
      final data = jsonDecode(body);

      await conn.query(
        "INSERT INTO favorites (user_id, song_id, title, artist, url, cover) VALUES (?, ?, ?, ?, ?, ?)",
        [
          data['user_id'],
          data['song_id'],
          data['title'],
          data['artist'],
          data['url'],
          data['cover']
        ],
      );

      await conn.close();

      return Response.ok(
        jsonEncode({"message": "Added to favorites ❤️"}),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}