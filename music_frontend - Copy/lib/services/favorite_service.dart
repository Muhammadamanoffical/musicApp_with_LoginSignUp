import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String key = "favorites";

  // ✅ Get all favorites
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  // ✅ Check if song is favorite
  static Future<bool> isFavorite(String url) async {
    final favs = await getFavorites();
    return favs.contains(url);
  }

  // ✅ Add / Remove favorite
  static Future<void> toggleFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(key) ?? [];

    if (favs.contains(url)) {
      favs.remove(url);
    } else {
      favs.add(url);
    }

    await prefs.setStringList(key, favs);
  }
}