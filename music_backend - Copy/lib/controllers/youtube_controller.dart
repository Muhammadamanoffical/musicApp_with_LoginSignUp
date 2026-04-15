import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeController {

  static Future<Response> getAudio(Request request) async {
    try {
      final yt = YoutubeExplode();

      final videoId = request.url.queryParameters['id'];

      if (videoId == null) {
        return Response.badRequest(body: "Missing video id");
      }

      final video = await yt.videos.get(videoId);
      final manifest = await yt.videos.streamsClient.getManifest(video.id);

      final audioStream = manifest.audioOnly.withHighestBitrate();

      final streamUrl = audioStream.url.toString();

      yt.close();

      return Response.ok(
        jsonEncode({
          "title": video.title,
          "audioUrl": streamUrl,
        }),
        headers: {"Content-Type": "application/json"},
      );

    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({"error": e.toString()}),
      );
    }
  }
}