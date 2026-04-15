import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/favorite_service.dart';

class SongCard extends StatefulWidget {
  final Song song;
  final VoidCallback onTap;

  const SongCard({super.key, required this.song, required this.onTap});

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  bool isFav = false;

  @override
  void initState() {
    super.initState();
    checkFav();
  }

  void checkFav() async {
    final fav = await FavoriteService.isFavorite(widget.song.url);
    setState(() => isFav = fav);
  }

  void toggle() async {
    await FavoriteService.toggleFavorite(widget.song.url);
    checkFav();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF1C1C1C),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(song.cover,
                      height: 120, fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                Text(song.title,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis),
                Text(song.artist,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),

            // ❤️ HEART BUTTON
            Positioned(
              right: 10,
              top: 10,
              child: GestureDetector(
                onTap: toggle,
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}