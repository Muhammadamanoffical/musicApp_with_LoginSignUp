import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/api_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? fileBytes;

  final titleCtrl = TextEditingController();
  final artistCtrl = TextEditingController();
  final coverCtrl = TextEditingController();

  bool loading = false;

  Future<void> pickSong() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true, // ✅ IMPORTANT FIX
    );

    if (result != null) {
      setState(() {
        fileBytes = result.files.first.bytes;
      });
    }
  }

  Future<void> upload() async {
    if (titleCtrl.text.isEmpty ||
        artistCtrl.text.isEmpty ||
        coverCtrl.text.isEmpty ||
        fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final ok = await ApiService.uploadSong(
      title: titleCtrl.text,
      artist: artistCtrl.text,
      cover: coverCtrl.text,
      fileBytes: fileBytes!,
    );

    setState(() => loading = false);

    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("Upload Song")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input(titleCtrl, "Song Title"),
            _input(artistCtrl, "Artist"),
            _input(coverCtrl, "Cover URL"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickSong,
              child: Text(fileBytes == null ? "Pick Song" : "Song Selected"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : upload,
              child: Text(loading ? "Uploading..." : "Upload"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: h,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}