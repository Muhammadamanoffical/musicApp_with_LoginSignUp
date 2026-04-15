import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/song_model.dart';
import '../widgets/song_card.dart';
import '../widgets/mini_player.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> songs = [];
  Song? currentSong;

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    songs = await ApiService.fetchSongs();
    setState(() {});
  }

  void playSong(Song song) {
    setState(() {
      currentSong = song;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(song: song),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ✅ NO COLUMN, NO STACK → CLEAN SAFE LAYOUT
      body: SafeArea(
        child: Stack(
          children: [
            // 🎵 MAIN CONTENT
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                const SizedBox(height: 10),

                const Text(
                  "🔥 Trending",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      return SongCard(
                        song: songs[index],
                        onTap: () => playSong(songs[index]),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "🎶 All Songs",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ...songs.map((song) {
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        song.cover,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () => playSong(song),
                  );
                }),
              ],
            ),

            // 🎵 MINI PLAYER FIXED OVERLAY (SAFE)
            if (currentSong != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: MiniPlayer(
                    song: currentSong!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlayerScreen(song: currentSong!),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}