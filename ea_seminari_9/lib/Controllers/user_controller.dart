import 'dart:convert';
import 'package:get/get.dart';
import '../Models/user.dart';
import '../Interceptor/auth_interceptor.dart';

class UserController extends GetxController {
  final String apiUrl = 'http://localhost:3000/api/user';
  var isLoading = true.obs;
  var users = <User>[].obs;
  final client = AuthInterceptor();


  Future<List<User>> fetchUsers() async {
    try {
      isLoading(true);
      final response = await client.get(Uri.parse(apiUrl),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final usersList = data.map((json) => User.fromJson(json)).toList();
        users.assignAll(usersList);
        return usersList;
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchUsers: $e');
      throw Exception('Error al cargar usuarios: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<User> fetchUserById(String id) async {
    try {
      isLoading(true);
      final response = await client.get(Uri.parse('$apiUrl/$id')
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Error al cargar el usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchUserById: $e');
      throw Exception('Error al cargar el usuario: $e');
    }
  }
}