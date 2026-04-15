import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Song> songs = [];
  List<Song> filtered = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    songs = await ApiService.fetchSongs();
    filtered = songs;
    setState(() {});
  }

  void search(String q) {
    filtered = songs
        .where((s) => s.title.toLowerCase().contains(q.toLowerCase()))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: search,
          decoration: const InputDecoration(hintText: "Search..."),
        ),
      ),
      body: ListView(
        children: filtered
            .map((s) => ListTile(
                  title: Text(s.title),
                  subtitle: Text(s.artist),
                ))
            .toList(),
      ),
    );
  }
}