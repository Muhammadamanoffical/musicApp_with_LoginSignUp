import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import 'player_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Song> favSongs = [];

  @override
  void initState() {
    super.initState();
    loadFavs();
  }

  Future<void> loadFavs() async {
    final allSongs = await ApiService.fetchSongs();
    final favUrls = await FavoriteService.getFavorites();

    favSongs =
        allSongs.where((song) => favUrls.contains(song.url)).toList();

    setState(() {});
  }

  void play(Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("❤️ Favorites"),
      ),
      body: favSongs.isEmpty
          ? const Center(
              child: Text("No favorites yet",
                  style: TextStyle(color: Colors.white)))
          : ListView.builder(
              itemCount: favSongs.length,
              itemBuilder: (context, i) {
                final song = favSongs[i];

                return ListTile(
                  leading: Image.network(song.cover, width: 50),
                  title: Text(song.title,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(song.artist,
                      style: const TextStyle(color: Colors.grey)),
                  onTap: () => play(song),
                );
              },
            ),
    );
  }
}