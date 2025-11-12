import 'package:ea_seminari_9/Models/user.dart';
import 'package:ea_seminari_9/Services/user_services.dart';
import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';

class UserController extends GetxController {
  var isLoading = true.obs;
  var userList = <User>[].obs;
  var selectedUser = Rxn<User>();
  final UserServices _userServices;

  UserController(this._userServices);
  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  void fetchUsers() async {
    try {
      isLoading(true);
      var users = await _userServices.fetchUsers(); 
      if (users.isNotEmpty) {
        userList.assignAll(users);
      }
    } finally {
      isLoading(false);
    }
  }
  fetchUserById(String id) async{
    try {
      isLoading(true);
      var user = await _userServices.fetchUserById(id);
      selectedUser.value = user;
      }
      catch(e){
        Get.snackbar(
        "Error al cargar",
        "No se pudo encontrar el usuario: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
  updateUserByid(String id, Map<String, dynamic> newData) async {
  try {
    isLoading(true);
    var user = await _userServices.updateUserById(id, newData);
    selectedUser.value = user;

    final authController = Get.find<AuthController>();
    if (authController.currentUser.value?.id == id) {
      authController.currentUser.value = user;
    }

  } catch (e) {
      Get.snackbar(
        "Error al cargar",
        "No se pudo encontrar el usuario: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading(false);
  }
}

disableUserByid(String id,password) async {
  try {
    isLoading(true);
    bool disableuser  = await _userServices.disableUserById(id, password);
    if (disableuser == true){
      isLoading(false);
      Get.offAllNamed('/login');
    }

  } catch (e) {
      Get.snackbar(
        "Error al cargar",
        "No se pudo encontrar el usuario: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading(false);
  }
}
}