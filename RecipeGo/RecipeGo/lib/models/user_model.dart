
class UserModel {
  final String uid;
  final String email;
  final String username;
  final bool isGuest;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.isGuest = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'isGuest': isGuest,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? 'User',
      isGuest: map['isGuest'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  static UserModel createGuestUser(String uid) {
    return UserModel(
      uid: uid,
      email: 'guest@recipego.com',
      username: 'Guest User',
      isGuest: true,
      createdAt: DateTime.now(),
    );
  }
}
