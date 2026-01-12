import 'package:ea_seminari_9/Models/user.dart';
import 'package:ea_seminari_9/Services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar
import '../Controllers/auth_controller.dart';
import '../Services/socket_services.dart';
import '../utils/logger.dart';
import 'dart:io';

class UserController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final SocketService _socketService;
  var isLoading = true.obs;
  var isMoreLoading = false.obs;
  var userList = <User>[].obs;
  var selectedUser = Rxn<User>();
  var friendsList = <User>[].obs;
  var friendsRequests = <User>[].obs;
  var friendsCurrentPage = 1.obs;
  var friendsTotalPages = 1.obs;
  var isMoreFriendsLoading = false.obs;

  var blockedUsersList = <User>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalUsers = 0.obs;
  final int limit = 20;
  final int friendsLimit = 20;

  final TextEditingController searchEditingController = TextEditingController();
  final UserServices _userServices;

  final ScrollController scrollController = ScrollController();
  UserController(this._userServices, this._socketService);

  @override
  void onInit() {
    _initSocketConnection();
    fetchUsers(1);
    fetchFriends();

    // Escuchar cambios en el usuario para refrescar datos cuando se haga login/auto-login
    ever(authController.currentUser, (user) {
      if (user != null && user.id.isNotEmpty) {
        logger.i(
          '👤 Usuario detectado en UserController, refrescando amigos...',
        );
        fetchFriends();
        fetchRequest();
        _initSocketConnection();
      }
    });

    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoading.value &&
            !isMoreLoading.value &&
            currentPage.value < totalPages.value) {
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
      final data = await _userServices.fetchUsers(page: page, limit: limit);

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
      Get.snackbar(
        translate('common.error'),
        translate('chat.errors.load_contacts'),
      );
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
      logger.i('🔍 Búsqueda de usuario: $query');
      isLoading(true);

      final User? user = await _userServices.getUserByUsername(query);

      if (user != null) {
        logger.i('✅ Usuario encontrado: ${user.username}');
        userList.assignAll([user]);
      } else {
        logger.w('⚠️ No se encontró usuario con el nombre: $query');
        userList.clear();
        Get.snackbar(
          translate('common.search'),
          translate('users.empty_search'), // 'No se encontró ningún usuario'
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      logger.e('❌ Error en búsqueda de usuario', error: e);
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshUsers() async {
    searchEditingController.clear();
    await fetchUsers(1);
  }

  fetchUserById(String id) async {
    try {
      isLoading(true);
      var user = await _userServices.fetchUserById(id);
      selectedUser.value = user;
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

  updateUserByid(String id, Map<String, dynamic> newData) async {
    try {
      logger.i('📁 Actualizando usuario: $id');
      isLoading(true);
      var user = await _userServices.updateUserById(id, newData);
      selectedUser.value = user;
      logger.i('✅ Usuario actualizado exitosamente');

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

  disableUserByid(String id, password) async {
    try {
      isLoading(true);
      bool disableuser = await _userServices.disableUserById(id, password);
      if (disableuser == true) {
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

  Future<void> fetchFriends({int page = 1}) async {
    try {
      final user = authController.currentUser.value;
      if (user == null || user.id.isEmpty) {
        logger.w('⚠️ No se pueden cargar amigos: ID de usuario no disponible');
        return;
      }
      var id = user.id;
      if (page == 1) {
        isLoading.value = true;
      } else {
        isMoreFriendsLoading.value = true;
      }

      final data = await _userServices.fetchFriends(
        id,
        page: page,
        limit: friendsLimit,
      );
      final List<User> newFriends = data['friends'];

      if (page == 1) {
        friendsList.assignAll(newFriends);
      } else {
        friendsList.addAll(newFriends);
      }

      friendsCurrentPage.value = data['currentPage'];
      friendsTotalPages.value = data['totalPages'];
    } catch (e) {
      logger.e('❌ Error al cargar amigos', error: e);
    } finally {
      isLoading.value = false;
      isMoreFriendsLoading.value = false;
    }
  }

  void loadMoreFriends() {
    if (friendsCurrentPage.value < friendsTotalPages.value &&
        !isMoreFriendsLoading.value) {
      fetchFriends(page: friendsCurrentPage.value + 1);
    }
  }

  Future<void> fetchRequest() async {
    try {
      final user = authController.currentUser.value;
      if (user == null || user.id.isEmpty) return;
      var id = user.id;
      isLoading(true);
      logger.d('📄 Creando lista de solicitudes');
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
      await _userServices.acceptFriendRequest(userId, requester.id);

      friendsRequests.removeWhere((u) => u.id == requester.id);
      fetchFriends();
      Get.snackbar(
        translate('common.success'),
        translate('users.friendship_accepted'), // 'Amistad aceptada'
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _initSocketConnection() {
    // Obtenemos el ID del usuario actual desde el AuthController
    final userId = authController.currentUser.value?.id;

    if (userId != null && userId.isNotEmpty) {
      logger.i('🔌 Inicializando conexión Socket para $userId');
      _socketService.connectWithUserId(userId);
    }
  }

  @override
  void onClose() {
    _socketService.disconnect();
    super.onClose();
  }

  // --- MÉTODOS DE FOTO DE PERFIL ---

  String? getFullPhotoUrl(String? photoPath) {
    return _userServices.getFullPhotoUrl(photoPath);
  }

  Future<void> uploadProfilePhoto(String id, File imageFile) async {
    try {
      isLoading(true);
      await _userServices.uploadProfilePhoto(id, imageFile);
      Get.snackbar(
        translate('common.success'),
        translate('profile.update_success'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteProfilePhoto(String id) async {
    try {
      isLoading(true);
      bool success = await _userServices.deleteProfilePhoto(id);
      if (success) {
        Get.snackbar(
          translate('common.success'),
          'Foto eliminada',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // --- MÉTODOS DE BLOQUEO ---

  void fetchBlockedUsers() async {
    try {
      isLoading(true);
      var blocked = await _userServices.fetchBlockedUsers();
      blockedUsersList.assignAll(blocked);
    } catch (e) {
      logger.e('❌ Error al cargar bloqueados', error: e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> blockUser(String blockId) async {
    try {
      isLoading(true);
      await _userServices.blockUser(blockId);

      // Eliminar de amigos localmente
      friendsList.removeWhere((u) => u.id == blockId);
      // Eliminar de la lista de usuarios si está ahí
      userList.removeWhere((u) => u.id == blockId);

      // Actualizar el usuario actual localmente (añadir a blockedUsers si lo tenemos)
      final currentUser = authController.currentUser.value;
      if (currentUser != null) {
        List<String> newBlocked = List.from(currentUser.blockedUsers ?? []);
        if (!newBlocked.contains(blockId)) {
          newBlocked.add(blockId);
          authController.currentUser.value = User(
            id: currentUser.id,
            username: currentUser.username,
            gmail: currentUser.gmail,
            birthday: currentUser.birthday,
            profilePhoto: currentUser.profilePhoto,
            token: currentUser.token,
            refreshToken: currentUser.refreshToken,
            online: currentUser.online,
            blockedUsers: newBlocked,
          );
        }
      }

      Get.snackbar(
        translate('common.success'),
        translate('users.block_success'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> unblockUser(String blockId) async {
    try {
      isLoading(true);
      await _userServices.unblockUser(blockId);

      blockedUsersList.removeWhere((u) => u.id == blockId);

      // Actualizar el usuario actual localmente
      final currentUser = authController.currentUser.value;
      if (currentUser != null && currentUser.blockedUsers != null) {
        List<String> newBlocked = List.from(currentUser.blockedUsers!);
        newBlocked.remove(blockId);
        authController.currentUser.value = User(
          id: currentUser.id,
          username: currentUser.username,
          gmail: currentUser.gmail,
          birthday: currentUser.birthday,
          profilePhoto: currentUser.profilePhoto,
          token: currentUser.token,
          refreshToken: currentUser.refreshToken,
          online: currentUser.online,
          blockedUsers: newBlocked,
        );
      }

      Get.snackbar(
        translate('common.success'),
        translate('users.unblock_success'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}
