class User {
  final String id;
  final String username;
  final String gmail;
  final String birthday;
  final String? password;
  final String? token;
  final String? refreshToken;
  final bool? online;

  User({
    required this.id,
    required this.username,
    required this.gmail,
    required this.birthday,
    this.online,
    this.password,
    this.token,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      gmail: json['gmail'] ?? '',
      birthday: json['birthday'] ?? '',
      token: json['token'],
      refreshToken: json['refreshToken'],
      online: json['online'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'gmail': gmail,
      'password': password,
      'birthday': birthday,
      'online': online,
    };
  }
}