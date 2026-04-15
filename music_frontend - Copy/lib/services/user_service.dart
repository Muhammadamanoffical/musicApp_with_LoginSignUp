import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserService {
  static const String baseUrl = 'http://127.0.0.1:8080';

  // GET USER PROFILE
  static Future<User?> getUserProfile(int userId) async {
    try {
      print('Fetching user profile from database: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile?id=$userId'),
      ).timeout(const Duration(seconds: 15));

      print('User profile response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        print('User profile loaded from database: ${user.username}');
        return user;
      }
      return null;
    } catch (e) {
      print('Get User Profile Error: $e');
      return null;
    }
  }
static Future<String?> pickImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);

  if (picked != null) {
    return picked.path;
  }
  return null;
}
  // UPDATE PROFILE - Saves only to database
  static Future<bool> updateUserProfile({
    required int userId,
    required String bio,
    required String profilePic,
  }) async {
    try {
      print('Updating user profile in database: $userId');

      final response = await http.post(
        Uri.parse('$baseUrl/user/update-profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userId,
          'bio': bio,
          'profile_pic': profilePic,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Update profile response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Profile updated in database successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Update Profile Error: $e');
      return false;
    }
  }

  // UPDATE BIO - Saves only to database
  static Future<bool> updateBio({
    required int userId,
    required String bio,
  }) async {
    try {
      print('Updating bio in database for user: $userId');

      final response = await http.post(
        Uri.parse('$baseUrl/user/update-bio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userId,
          'bio': bio,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Update bio response: ${response.statusCode}');
      print('Bio saved to database: $bio');

      return response.statusCode == 200;
    } catch (e) {
      print('Update Bio Error: $e');
      return false;
    }
  }

  // UPDATE PROFILE PICTURE - Saves only to database
  static Future<bool> updateProfilePicture({
    required int userId,
    required String profilePicUrl,
  }) async {
    try {
      print('Updating profile picture in database for user: $userId');

      final response = await http.post(
        Uri.parse('$baseUrl/user/update-picture'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userId,
          'profile_pic': profilePicUrl,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Update profile picture response: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Update Profile Picture Error: $e');
      return false;
    }
  }

  // GET USER FAVORITES
  static Future<List<dynamic>> getUserFavorites(int userId) async {
    try {
      print('Fetching favorites from database for user: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/user/favorites?id=$userId'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final favorites = jsonDecode(response.body);
        print('Loaded ${(favorites as List).length} favorites from database');
        return favorites;
      }
      return [];
    } catch (e) {
      print('Get Favorites Error: $e');
      return [];
    }
  }

  // DELETE ACCOUNT
  static Future<bool> deleteAccount({
    required int userId,
    required String password,
  }) async {
    try {
      print('Deleting account from database: $userId');

      final response = await http.post(
        Uri.parse('$baseUrl/user/delete-account'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userId,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      print('Delete Account Error: $e');
      return false;
    }
  }

  // SEARCH USERS
  static Future<List<User>> searchUsers(String query) async {
    try {
      print('Searching users in database: $query');

      final response = await http.get(
        Uri.parse('$baseUrl/users/search?q=$query'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Search Users Error: $e');
      return [];
    }
  }

  // GET ALL USERS
  static Future<List<User>> getAllUsers() async {
    try {
      print('Fetching all users from database');

      final response = await http.get(
        Uri.parse('$baseUrl/users/all'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get All Users Error: $e');
      return [];
    }
  }
}