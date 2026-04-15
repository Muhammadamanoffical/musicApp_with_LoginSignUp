import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/favorite_service.dart';

class PlayerScreen extends StatefulWidget {
  final Song song;

  const PlayerScreen({super.key, required this.song});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer player = AudioPlayer();

  bool loading = true;
  bool isFav = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    initSong();
    checkFav();
  }

  Future<void> initSong() async {
    await player.setUrl(widget.song.url);
    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> checkFav() async {
    isFav = await FavoriteService.isFavorite(widget.song.url);
    if (mounted) setState(() {});
  }

  void togglePlay() async {
    if (player.playing) {
      await player.pause();
      _controller.reverse();
    } else {
      await player.play();
      _controller.forward();
    }
    setState(() {});
  }

  void toggleFav() async {
    await FavoriteService.toggleFavorite(widget.song.url);
    isFav = !isFav;
    setState(() {});
  }

  String format(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    player.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 🎨 BACKGROUND IMAGE
                Positioned.fill(
                  child: Image.network(
                    widget.song.cover,
                    fit: BoxFit.cover,
                  ),
                ),

                // 🌫 BLUR
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // 🔝 TOP BAR
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: toggleFav,
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: isFav ? 1.3 : 1,
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 🎵 COVER
                        Hero(
                          tag: widget.song.url,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              widget.song.cover,
                              height: 260,
                              width: 260,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // 🎶 TITLE
                        Text(
                          widget.song.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          widget.song.artist,
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 25),

                        // ⏱ PROGRESS BAR
                        StreamBuilder<Duration>(
                          stream: player.positionStream,
                          builder: (context, snapshot) {
                            final pos = snapshot.data ?? Duration.zero;
                            final dur = player.duration ??
                                const Duration(seconds: 1);

                            final max = dur.inSeconds.toDouble();
                            final value =
                                pos.inSeconds.toDouble().clamp(0.0, max);

                            return Column(
                              children: [
                                Slider(
                                  min: 0,
                                  max: max,
                                  value: value,
                                  activeColor: const Color(0xFF1DB954),
                                  onChanged: (v) {
                                    player.seek(
                                      Duration(seconds: v.toInt()),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        format(pos),
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                      Text(
                                        format(dur),
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // 🎛 CONTROLS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shuffle,
                                color: Colors.white54),

                            const SizedBox(width: 20),

                            GestureDetector(
                              onTap: togglePlay,
                              child: Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1DB954),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.green.withOpacity(0.6),
                                      blurRadius: 20,
                                    )
                                  ],
                                ),
                                child: Icon(
                                  player.playing
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            const Icon(Icons.repeat,
                                color: Colors.white54),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}