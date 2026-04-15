import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../db.dart';

class SongController {
  static Future<Response> getSongs(Request request) async {
    try {
      final conn = await connectDB();
      var results = await conn.query('SELECT * FROM songs');

      List<Map<String, dynamic>> songs = [];

      for (var row in results) {
        songs.add({
          'id': row[0],
          'title': row[1]?.toString() ?? '',
          'artist': row[2]?.toString() ?? '',
          'url': row[3]?.toString() ?? '',
          'cover': row[4]?.toString() ?? '',
        });
      }

      await conn.close();

      return Response.ok(
        jsonEncode(songs),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("❌ GET SONGS ERROR: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  static Future<Response> addSong(Request request) async {
    try {
      final conn = await connectDB();
      var body = await request.readAsString();
      var data = jsonDecode(body);

      await conn.query(
        'INSERT INTO songs (title, artist, url, cover) VALUES (?, ?, ?, ?)',
        [data['title'], data['artist'], data['url'], data['cover']],
      );

      await conn.close();

      return Response.ok(
        jsonEncode({'message': 'Song added successfully ✅'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("❌ ADD SONG ERROR: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}