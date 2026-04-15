import 'dart:convert';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:bcrypt/bcrypt.dart';
import '../db.dart';

class AuthController {
  // Convert Blob to String
  static String _blobToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Uint8List) {
      try {
        return String.fromCharCodes(value);
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  // SIGNUP
  static Future<Response> signup(Request req) async {
    try {
      final conn = await connectDB();
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final username = data['username']?.toString().trim();
      final email = data['email']?.toString().trim();
      final password = data['password']?.toString();

      print('Signup attempt: username=$username, email=$email');

      if (username == null || username.isEmpty || username.length < 3) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({"error": "Username must be at least 3 characters"}),
        );
      }

      if (email == null ||
          email.isEmpty ||
          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid email format"}),
        );
      }

      if (password == null || password.isEmpty || password.length < 6) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({"error": "Password must be at least 6 characters"}),
        );
      }

      // CHECK IF USER EXISTS
      final existingUser = await conn.query(
        'SELECT id FROM users WHERE email = ? OR username = ?',
        [email, username],
      );

      if (existingUser.isNotEmpty) {
        await conn.close();
        print('User already exists');
        return Response.badRequest(
          body: jsonEncode({"error": "User already exists"}),
        );
      }

      // HASH PASSWORD
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // INSERT USER
      await conn.query(
        'INSERT INTO users (username, email, password_hash, bio, profile_pic) VALUES (?, ?, ?, ?, ?)',
        [
          username,
          email,
          hashedPassword,
          '',
          'https://via.placeholder.com/150?text=No+Image',
        ],
      );

      await conn.close();
      print('User registered successfully: $email');

      return Response.ok(
        jsonEncode({"message": "Signup successful! Please login."}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Signup Error: $e");
      return Response.internalServerError(
        body: jsonEncode({"error": e.toString()}),
      );
    }
  }

  // LOGIN - OPTIMIZED (SINGLE QUERY)
  static Future<Response> login(Request req) async {
    try {
      final conn = await connectDB();
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final email = data['email']?.toString().trim();
      final password = data['password']?.toString();

      print('Login attempt: email=$email');

      if (email == null || email.isEmpty) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({"error": "Email is required"}),
        );
      }

      if (password == null || password.isEmpty) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({"error": "Password is required"}),
        );
      }

      // SINGLE QUERY - Get all user data at once
      final result = await conn.query(
        'SELECT id, username, email, password_hash, bio, profile_pic FROM users WHERE email = ?',
        [email],
      );

      if (result.isEmpty) {
        await conn.close();
        print('User not found: $email');
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid email or password"}),
        );
      }

      final userRow = result.first;
      final userId = userRow[0] as int;
      final username = userRow[1].toString();
      final userEmail = userRow[2].toString();
      final storedHash = _blobToString(userRow[3]);
      final bio = _blobToString(userRow[4]);
      final profilePic = _blobToString(userRow[5]);

      print('User found: $username');

      if (storedHash.isEmpty) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid email or password"}),
        );
      }

      // VERIFY PASSWORD
      bool passwordMatch = false;
      try {
        passwordMatch = BCrypt.checkpw(password, storedHash);
      } catch (e) {
        print('BCrypt error: $e');
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid email or password"}),
        );
      }

      if (!passwordMatch) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({"error": "Invalid email or password"}),
        );
      }

      // GET FAVORITES - Single query
      final favResults = await conn.query(
        'SELECT url FROM favorites WHERE user_id = ? LIMIT 100',
        [userId],
      );

      final favorites =
          favResults.map((r) => r[0].toString()).toList();

      await conn.close();

      // BUILD RESPONSE
      final userResponse = {
        'id': userId,
        'username': username,
        'email': userEmail,
        'bio': bio.isEmpty ? '' : bio,
        'profile_pic': profilePic.isEmpty
            ? 'https://via.placeholder.com/150?text=No+Image'
            : profilePic,
        'favorites': favorites,
      };

      print('Login successful - bio: "$bio", favorites: ${favorites.length}');

      return Response.ok(
        jsonEncode({
          "message": "Login successful",
          "user": userResponse,
          "token": "temp_token_$userId",
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Login Error: $e");
      return Response.internalServerError(
        body: jsonEncode({"error": e.toString()}),
      );
    }
  }
}