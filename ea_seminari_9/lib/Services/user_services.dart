import'package:get/get.dart';
import 'package:ea_seminari_9/Models/user.dart';
import 'package:ea_seminari_9/Controllers/user_controller.dart';


class UserServices extends GetxController {
  var users = <User>[].obs;
  var isLoading = false.obs;

  final UserController _userController = UserController();

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      users.value = await _userController.fetchUsers();
    } catch (e) {
      print('Error cargando usuarios: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<User> getUserById(String id) async {
    try {
      isLoading.value = true;
      return await _userController.fetchUserById(id);
    } catch (e) {
      print('Error cargando usuario: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
