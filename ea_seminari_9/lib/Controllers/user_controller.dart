import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ea_seminari_9/Models/user.dart';

class UserController {
  final String apiUrl = 'http://localhost:3000/api/user';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar usuarios');
    }
  }

}
