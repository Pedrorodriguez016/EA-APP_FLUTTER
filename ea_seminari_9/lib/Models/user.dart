
class User {
  final String id;
  final String username;
  final String gmail;
  final String birthday;
  final String rol;


  User({
    required this.id,
    required this.username,
    required this.gmail,
    required this.birthday,
    required this.rol,


  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      gmail: json['gmail'],
      birthday: json['birthday'],
      rol: json['rol'],
     
    );
  }
}
