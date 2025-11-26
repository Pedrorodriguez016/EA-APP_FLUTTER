import 'package:ea_seminari_9/Models/user.dart';
import 'package:ea_seminari_9/Services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';

class UserController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  var isLoading = true.obs;
  var isMoreLoading = false.obs;
  var userList = <User>[].obs;
  var selectedUser = Rxn<User>();
  var friendsList = <User>[].obs;
  var friendsRequests = <User>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalUsers = 0.obs;
  final int limit = 10;
  final TextEditingController searchEditingController = TextEditingController();
  final UserServices _userServices;

  final ScrollController scrollController = ScrollController();

  UserController(this._userServices);
  @override
  void onInit() {
    fetchUsers(1);
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoading.value && !isMoreLoading.value && currentPage.value < totalPages.value) {
          loadMoreUsers();
        }
      }
    });
  }
  Future<void> fetchUsers(int page) async {
    if (page == 1) {
      isLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }

    try {
      final data = await _userServices.fetchUsers(
        page: page,
        limit: limit,
      );

      final List<User> newUsers = data['users'];

      if (page == 1) {
        userList.assignAll(newUsers);
      } else {
        userList.addAll(newUsers);
      }

      currentPage.value = data['currentPage'];
      totalPages.value = data['totalPages'];
      totalUsers.value = data['total'];
      
    } catch (e) {
      print("Error al cargar usuarios: $e");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false; 
    }
  }

  void loadMoreUsers() {
    if (currentPage.value < totalPages.value) {
      fetchUsers(currentPage.value + 1);
    }
  }

  void searchUsers(String searchEditingController) async {
   if (searchEditingController.isEmpty) {
      refreshUsers();
      return;
    }

    try {
      isLoading(true);
      
      final User? user = await _userServices.getUserByUsername(searchEditingController);

      if (user != null) {
        userList.assignAll([user]);
      } else {
        userList.clear();
        Get.snackbar(
          'Búsqueda', 
          'No se encontró ningún usuario con ese nombre',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2)
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Ocurrió un error al buscar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
    } finally {
      isLoading(false);
    }
  }

  void refreshUsers() {
    searchEditingController.clear(); 
    fetchUsers(1);
    Get.snackbar(
      'Actualizado',
      'Lista de usuarios actualizada',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: Colors.green
    );
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
        colorText: Colors.white,
        backgroundColor: Colors.red,
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
        colorText: Colors.white,
        backgroundColor: Colors.red,
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
        colorText: Colors.white,
        backgroundColor: Colors.red,
    );
  } finally {
    isLoading(false);
  }
}

void fetchFriends() async {
    try {
      var id = authController.currentUser.value!.id;
      isLoading(true);
      var friends = await _userServices.fetchFriends(id); 
      if (friends.isNotEmpty) {
        friendsList.assignAll(friends);
      }
    } finally {
      isLoading(false);
    }
  }
  void fetchRequest() async {
    try {
      var id = authController.currentUser.value!.id;
      isLoading(true);
      print("Creando lista de solicitudes");
      var friends = await _userServices.fetchRequest(id); 
      if (friends.isNotEmpty) {
        friendsRequests.assignAll(friends);
      }
    } finally {
      isLoading(false);
    }
  }
  void acceptFriendRequest(User requester) async {
   try {
      final userId = authController.currentUser.value!.id;
      await _userServices.acceptFriendRequest(userId, requester.id,);

      friendsRequests.removeWhere((u) => u.id == requester.id);
      fetchFriends(); // opcional: refrescar lista de amigos
      Get.snackbar('Solicitud', 
      'Amistad aceptada',
       snackPosition: SnackPosition.BOTTOM,
       backgroundColor: Colors.green,
       colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 
      'No se pudo aceptar la solicitud: $e',
       snackPosition: SnackPosition.BOTTOM,
       backgroundColor: Colors.red,
       colorText: Colors.white);
    }
  }
  // --- Rechazar solicitud ---
  void rejectFriendRequest(User requester) async {
    try {
      final userId = authController.currentUser.value!.id;
      await _userServices.rejectFriendRequest(userId, requester.id);

      // actualizar lista local
      friendsRequests.removeWhere((u) => u.id == requester.id);
      Get.snackbar('Solicitud', 
      'Solicitud rechazada',
       snackPosition: SnackPosition.BOTTOM,
       backgroundColor: Colors.red,
       colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 
      'No se pudo rechazar la solicitud: $e',
       snackPosition: SnackPosition.BOTTOM,
       backgroundColor: Colors.red,
       colorText: Colors.white);
    }
  }
  sendFriendRequest(String targetUserId) async {
    try {
      final userId = authController.currentUser.value!.id;
      await _userServices.sendFriendRequest(userId, targetUserId);
      Get.snackbar('Solicitud',
       'Solicitud de amistad enviada',
       backgroundColor: Colors.green,
       colorText: Colors.white,
       snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 
      'No se pudo enviar la solicitud: $e',
       backgroundColor: Colors.red,
       colorText: Colors.white,
       snackPosition: SnackPosition.BOTTOM);
    }
  }
}