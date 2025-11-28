import 'package:get/get.dart';
import '../Services/user_services.dart';
import '../Controllers/auth_controller.dart';
import '../Models/user.dart';

class ChatListController extends GetxController {
  // Inyectamos los servicios necesarios
  final UserServices _userServices;
  final AuthController _authController;

  ChatListController(this._userServices, this._authController);

  // Estado de la UI
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
        // Usamos la función que ya tienes en UserServices
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

  // Función para navegar al chat individual
  void goToChat(User friend) {
    Get.toNamed(
      '/chat', // Esta ruta debe coincidir con la de tu main.dart
      arguments: {
        'friendId': friend.id,
        'friendName': friend.username,
      },
    );
  }
}