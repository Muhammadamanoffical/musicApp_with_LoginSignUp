import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import '../lib/routes.dart';

void main() async {
  final router = getRouter();

  // ✅ CORS MIDDLEWARE
  final corsMiddleware = (shelf.Handler innerHandler) {
    return (request) async {
      // ✅ Handle OPTIONS preflight request
      if (request.method == 'OPTIONS') {
        return shelf.Response.ok(
          null,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods':
                'GET, POST, PUT, DELETE, OPTIONS, PATCH',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '3600',
          },
        );
      }

      // ✅ Handle actual request
      final response = await innerHandler(request);
      return response.change(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods':
              'GET, POST, PUT, DELETE, OPTIONS, PATCH',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          'Content-Type': 'application/json',
        },
      );
    };
  };

  final handler = shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(corsMiddleware)
      .addHandler(router);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('🎵 Server running on http://0.0.0.0:8080');
  print('📱 Access from mobile: http://127.0.0.1:8080/');
}
