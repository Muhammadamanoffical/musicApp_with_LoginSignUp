class User {
  final int id;
  final String username;
  final String email;
  final String bio;
  final String profilePic;
  final List<String> favorites; // List of song URLs

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.profilePic,
    required this.favorites,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'] ?? '',
      profilePic: json['profile_pic'] ?? 'https://via.placeholder.com/150?text=No+Image',
      favorites: List<String>.from(json['favorites'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'profile_pic': profilePic,
      'favorites': favorites,
    };
  }
}