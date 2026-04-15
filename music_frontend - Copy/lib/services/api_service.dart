import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import '../models/song_model.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8080";

  static Future<List<Song>> fetchSongs() async {
    final res = await http.get(Uri.parse('$baseUrl/songs'));

    final data = jsonDecode(res.body);
    return (data as List).map((e) => Song.fromJson(e)).toList();
  }

  // ✅ FIXED UPLOAD (WEB + MOBILE)
  static Future<bool> uploadSong({
    required String title,
    required String artist,
    required String cover,
    required Uint8List fileBytes,
  }) async {
    final base64File = base64Encode(fileBytes);

    final res = await http.post(
      Uri.parse('$baseUrl/upload'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "artist": artist,
        "cover": cover,
        "file": base64File,
      }),
    );

    return res.statusCode == 200;
  }
}