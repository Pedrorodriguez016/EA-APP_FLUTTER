class User {
  final String id;
  final String username;
  final String gmail;
  final String birthday;
  final String? profilePhoto;
  final String? password;
  final String? token;
  final String? refreshToken;
  final bool? online;

  User({
    required this.id,
    required this.username,
    required this.gmail,
    required this.birthday,
    this.profilePhoto,
    this.online,
    this.password,
    this.token,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
      username: json['username'] ?? '',
      gmail: json['gmail'] ?? '',
      birthday: json['birthday'] ?? '',
      profilePhoto: json['profilePhoto'],
      token: json['token'],
      refreshToken: json['refreshToken'],
      online: json['online'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'gmail': gmail,
      'password': password,
      'birthday': birthday,
      'profilePhoto': profilePhoto,
      'online': online,
    };
  }
}
