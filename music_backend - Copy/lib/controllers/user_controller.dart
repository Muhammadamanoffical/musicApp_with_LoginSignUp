import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../db.dart';

class UserController {
  // GET USER PROFILE BY ID
  static Future<Response> getUserProfile(Request req) async {
    try {
      final conn = await connectDB();
      final userId = req.url.queryParameters['id'];

      if (userId == null || userId.isEmpty) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({'error': 'User ID is required'}),
        );
      }

      final result = await conn.query(
        'SELECT id, username, email, bio, profile_pic FROM users WHERE id = ?',
        [int.parse(userId)],
      );

      if (result.isEmpty) {
        await conn.close();
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
        );
      }

      final userRow = result.first;
      final userId_val = userRow[0];
      final username = userRow[1].toString();
      final email = userRow[2].toString();
      final bio = userRow[3].toString();
      final profilePic = userRow[4].toString();

      // GET FAVORITES
      final favResults = await conn.query(
        'SELECT url FROM favorites WHERE user_id = ?',
        [userId_val],
      );

      final favorites = favResults.map((r) => r[0].toString()).toList();

      await conn.close();

      final user = {
        'id': userId_val,
        'username': username,
        'email': email,
        'bio': bio,
        'profile_pic': profilePic,
        'favorites': favorites,
      };

      print('Retrieved user profile: $username');

      return Response.ok(
        jsonEncode(user),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Get User Profile Error: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // UPDATE USER PROFILE
  static Future<Response> updateUserProfile(Request req) async {
    try {
      final conn = await connectDB();
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final userId = data['id'];
      final username = data['username']?.toString().trim();
      final bio = data['bio']?.toString().trim() ?? '';
      final profilePic = data['profile_pic']?.toString().trim();

      print('Updating user: $userId');

      if (userId == null) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({'error': 'User ID is required'}),
        );
      }

      // Check if user exists
      final userExists = await conn.query(
        'SELECT id FROM users WHERE id = ?',
        [userId],
      );

      if (userExists.isEmpty) {
        await conn.close();
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
        );
      }

      // Update profile
      await conn.query(
        'UPDATE users SET bio = ?, profile_pic = ? WHERE id = ?',
        [bio, profilePic, userId],
      );

      await conn.close();

      print('User profile updated: $userId');

      return Response.ok(
        jsonEncode({'message': 'Profile updated successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Update User Profile Error: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // UPDATE PROFILE PICTURE
  static Future<Response> updateProfilePicture(Request req) async {
    try {
      final conn = await connectDB();
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final userId = data['id'];
      final profilePicUrl = data['profile_pic']?.toString().trim();

      print('Updating profile picture for user: $userId');

      if (userId == null || profilePicUrl == null || profilePicUrl.isEmpty) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({'error': 'User ID and profile picture URL required'}),
        );
      }

      await conn.query(
        'UPDATE users SET profile_pic = ? WHERE id = ?',
        [profilePicUrl, userId],
      );

      await conn.close();

      print('Profile picture updated for user: $userId');

      return Response.ok(
        jsonEncode({'message': 'Profile picture updated successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Update Profile Picture Error: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // UPDATE BIO
static Future<Response> updateBio(Request req) async {
  try {
    final conn = await connectDB();
    final body = await req.readAsString();
    final data = jsonDecode(body);

    final userId = data['id'];
    final bio = data['bio']?.toString().trim() ?? '';

    print('Updating bio for user: $userId');

    if (userId == null) {
      await conn.close(); 
      return Response.badRequest(
        body: jsonEncode({'error': 'User ID is required'}),
      );
    }

    // Update bio in database
    await conn.query(
      'UPDATE users SET bio = ? WHERE id = ?',
      [bio, userId],
    );

    // Get updated user
    final result = await conn.query(
      'SELECT id, username, email, bio, profile_pic FROM users WHERE id = ?',
      [userId],
    );

    if (result.isEmpty) {
      await conn.close();
      return Response.notFound(
        jsonEncode({'error': 'User not found'}),
      );
    }

    final userRow = result.first;

    // Get favorites
    final favResults = await conn.query(
      'SELECT url FROM favorites WHERE user_id = ?',
      [userId],
    );

    final favorites = favResults.map((r) => r[0].toString()).toList();

    await conn.close();

    print('Bio updated for user: $userId');

    // Return updated user
    return Response.ok(
      jsonEncode({
        'id': userRow[0],
        'username': userRow[1].toString(),
        'email': userRow[2].toString(),
        'bio': userRow[3].toString(),
        'profile_pic': userRow[4].toString(),
        'favorites': favorites,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print("Update Bio Error: $e");
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}
  // CHANGE PASSWORD
  static Future<Response> changePassword(Request req) async {
    try {
      final conn = await connectDB();
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final userId = data['id'];
      final oldPassword = data['old_password']?.toString();
      final newPassword = data['new_password']?.toString();

      print('Changing password for user: $userId');

      if (userId == null || oldPassword == null || newPassword == null) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({'error': 'User ID, old password, and new password required'}),
        );
      }

      if (newPassword.length < 6) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({'error': 'New password must be at least 6 characters'}),
        );
      }

      // Get user
      final userResult = await conn.query(
        'SELECT password_hash FROM users WHERE id = ?',
        [userId],
      );

      if (userResult.isEmpty) {
        await conn.close();
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
        );
      }

      print('Password change completed for user: $userId');

      return Response.ok(
        jsonEncode({'message': 'Password changed successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Change Password Error: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // GET USER FAVORITES
  static Future<Response> getUserFavorites(Request req) async {
    try {
      final conn = await connectDB();
      final userId = req.url.queryParameters['id'];

      if (userId == null || userId.isEmpty) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({'error': 'User ID is required'}),
        );
      }

      final results = await conn.query(
        '''SELECT id, song_id, title, artist, url, cover, added_at 
           FROM favorites WHERE user_id = ? ORDER BY added_at DESC''',
        [int.parse(userId)],
      );

      List<Map<String, dynamic>> favorites = [];

      for (var row in results) {
        favorites.add({
          'id': row[0],
          'song_id': row[1],
          'title': row[2].toString(),
          'artist': row[3].toString(),
          'url': row[4].toString(),
          'cover': row[5].toString(),
          'added_at': row[6].toString(),
        });
      }

      await conn.close();

      print('Retrieved ${favorites.length} favorites for user: $userId');

      return Response.ok(
        jsonEncode(favorites),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Get User Favorites Error: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // DELETE USER ACCOUNT
  static Future<Response> deleteUserAccount(Request req) async {
    try {
      final conn = await connectDB();
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final userId = data['id'];
      final password = data['password']?.toString();

      print('Delete account request for user: $userId');

      if (userId == null || password == null) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({'error': 'User ID and password required'}),
        );
      }

      // Get user
      final userResult = await conn.query(
        'SELECT password_hash FROM users WHERE id = ?',
        [userId],
      );

      if (userResult.isEmpty) {
        await conn.close();
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
        );
      }

      // Delete favorites first (foreign key constraint)
      await conn.query('DELETE FROM favorites WHERE user_id = ?', [userId]);

      // Delete sessions
      await conn.query('DELETE FROM sessions WHERE user_id = ?', [userId]);

      // Delete user
      await conn.query('DELETE FROM users WHERE id = ?', [userId]);

      await conn.close();

      print('User account deleted: $userId');

      return Response.ok(
        jsonEncode({'message': 'Account deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Delete User Account Error: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // GET ALL USERS (ADMIN ONLY)
  static Future<Response> getAllUsers(Request req) async {
    try {
      final conn = await connectDB();

      var results = await conn.query(
        'SELECT id, username, email, bio, profile_pic, created_at FROM users ORDER BY created_at DESC',
      );

      List<Map<String, dynamic>> users = [];

      for (var row in results) {
        users.add({
          'id': row[0],
          'username': row[1].toString(),
          'email': row[2].toString(),
          'bio': row[3].toString(),
          'profile_pic': row[4].toString(),
          'created_at': row[5].toString(),
        });
      }

      await conn.close();

      print('Retrieved ${users.length} users');

      return Response.ok(
        jsonEncode(users),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Get All Users Error: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // SEARCH USERS
  static Future<Response> searchUsers(Request req) async {
    try {
      final conn = await connectDB();
      final query = req.url.queryParameters['q'] ?? '';

      if (query.isEmpty) {
        await conn.close();
        return Response.badRequest(
          body: jsonEncode({'error': 'Search query is required'}),
        );
      }

      var results = await conn.query(
        'SELECT id, username, email, bio, profile_pic FROM users WHERE username LIKE ? OR email LIKE ?',
        ['%$query%', '%$query%'],
      );

      List<Map<String, dynamic>> users = [];

      for (var row in results) {
        users.add({
          'id': row[0],
          'username': row[1].toString(),
          'email': row[2].toString(),
          'bio': row[3].toString(),
          'profile_pic': row[4].toString(),
        });
      }

      await conn.close();

      print('Search users found ${users.length} results for: $query');

      return Response.ok(
        jsonEncode(users),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Search Users Error: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}