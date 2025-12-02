import 'package:get/get.dart';
import '../Services/user_services.dart';
import '../Controllers/auth_controller.dart';
import '../Models/user.dart';

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
      
      if (myId != null) {
        List<User> friends = await _userServices.fetchFriends(myId);
        friendsList.assignAll(friends);
      }
    } catch (e) {
      print('Error cargando chats: $e');
      Get.snackbar('Error', 'No se pudieron cargar los contactos');
    } finally {
      isLoading(false);
    }
  }

  void goToChat(User friend) {
    Get.toNamed(
      '/chat',
      arguments: {
        'friendId': friend.id,
        'friendName': friend.username,
      },
    );
  }
}