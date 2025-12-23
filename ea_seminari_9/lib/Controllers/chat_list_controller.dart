import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import '../Services/user_services.dart';
import '../Controllers/auth_controller.dart';
import '../Models/user.dart';
import '../utils/logger.dart';

class ChatListController extends GetxController {
  final UserServices _userServices;
  final AuthController _authController;

  ChatListController(this._userServices, this._authController);

  var friendsList = <User>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadFriends();
  }

  void loadFriends() async {
    try {
      isLoading(true);
      final myId = _authController.currentUser.value?.id;
      logger.i('👥 Cargando lista de amigos');

      if (myId != null) {
        List<User> friends = await _userServices.fetchFriends(myId);
        friendsList.assignAll(friends);
        logger.i('✅ Lista de amigos cargada: ${friends.length} amigos');
      } else {
        logger.w('⚠️ Usuario no autenticado, no se pueden cargar amigos');
      }
    } catch (e) {
      logger.e('❌ Error cargando chats', error: e);
      Get.snackbar(
        translate('common.error'),
        translate('chat.errors.load_contacts'),
      );
    } finally {
      isLoading(false);
    }
  }

  void goToChat(User friend) {
    logger.i('💬 Abriendo chat con: ${friend.username}');
    Get.toNamed(
      '/chat',
      arguments: {'friendId': friend.id, 'friendName': friend.username},
    );
  }
}
