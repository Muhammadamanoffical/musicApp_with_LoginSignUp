class User {
  final int? id;
  final String username;
  final String email;
  final String passwordHash;
  final String bio;
  final String profilePic;
  final List<String> favorites;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.bio = '',
    this.profilePic = 'https://via.placeholder.com/150?text=No+Image',
    this.favorites = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'bio': bio,
    'profile_pic': profilePic,
    'favorites': favorites,
  };
}