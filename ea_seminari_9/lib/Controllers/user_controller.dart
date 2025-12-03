import 'package:ea_seminari_9/Models/user.dart';
import 'package:ea_seminari_9/Services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar
import '../Controllers/auth_controller.dart';
import '../Services/socket_services.dart';

class UserController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final SocketService _socketService;
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
  UserController(this._userServices, this._socketService);

  @override
  void onInit() {
    _initSocketConnection();
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

  void searchUsers(String query) async {
   if (query.isEmpty) {
      refreshUsers();
      return;
    }

    try {
      isLoading(true);
      
      final User? user = await _userServices.getUserByUsername(query);

      if (user != null) {
        userList.assignAll([user]);
      } else {
        userList.clear();
        Get.snackbar(
          translate('common.search'),
          translate('users.empty_search'), // 'No se encontró ningún usuario'
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2)
        );
      }
    } catch (e) {
      Get.snackbar(
        translate('common.error'), 
        e.toString(),
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
  }

  fetchUserById(String id) async{
    try {
      isLoading(true);
      var user = await _userServices.fetchUserById(id);
      selectedUser.value = user;
      }
      catch(e){
        Get.snackbar(
        translate('common.error'),
        e.toString(),
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
        translate('common.error'),
        e.toString(),
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
        translate('common.error'),
        e.toString(),
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
      fetchFriends(); 
      Get.snackbar(
        translate('common.success'), 
        translate('users.friendship_accepted'), // 'Amistad aceptada'
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
    } catch (e) {
      Get.snackbar(
        translate('common.error'), 
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    }
  }
  
  void rejectFriendRequest(User requester) async {
    try {
      final userId = authController.currentUser.value!.id;
      await _userServices.rejectFriendRequest(userId, requester.id);

      friendsRequests.removeWhere((u) => u.id == requester.id);
      Get.snackbar(
        translate('common.success'), 
        translate('users.req_rejected'), // 'Solicitud rechazada'
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    } catch (e) {
      Get.snackbar(
        translate('common.error'), 
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    }
  }
  sendFriendRequest(String targetUserId) async {
    try {
      final userId = authController.currentUser.value!.id;
      await _userServices.sendFriendRequest(userId, targetUserId);
      Get.snackbar(
       translate('common.success'),
       translate('users.req_sent'), // 'Solicitud de amistad enviada'
       backgroundColor: Colors.green,
       colorText: Colors.white,
       snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
       translate('common.error'), 
       e.toString(),
       backgroundColor: Colors.red,
       colorText: Colors.white,
       snackPosition: SnackPosition.BOTTOM);
    }
  }
  void _initSocketConnection() {
    // Obtenemos el ID del usuario actual desde el AuthController
    final userId = authController.currentUser.value?.id;
    
    if (userId != null) {
      print("UserController: Inicializando conexión Socket para $userId");
      _socketService.connectWithUserId(userId);
    }
  }
  @override
  void onClose() {
    _socketService.disconnect();
    super.onClose();
  }
}