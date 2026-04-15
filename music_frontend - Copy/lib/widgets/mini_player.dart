import 'package:flutter/material.dart';
import '../models/song_model.dart';

class MiniPlayer extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                song.cover,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey,
                    child: const Icon(Icons.music_note, color: Colors.white),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                song.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}