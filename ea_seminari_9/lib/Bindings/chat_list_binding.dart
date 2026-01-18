import 'package:get/get.dart';
import '../Controllers/chat_list_controller.dart';
import '../Controllers/user_controller.dart';
import '../Services/user_services.dart';
import '../Services/eventos_services.dart';
import '../Services/socket_services.dart';
import '../Controllers/auth_controller.dart';

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserServices>(() => UserServices());
    Get.lazyPut<EventosServices>(() => EventosServices());

    // Agregar UserController para el GlobalDrawer
    Get.lazyPut<UserController>(
      () => UserController(Get.find<UserServices>(), Get.find<SocketService>()),
    );
    Get.lazyPut<ChatListController>(
      () => ChatListController(
        Get.find<UserServices>(),
        Get.find<EventosServices>(),
        Get.find<AuthController>(),
      ),
    );
  }
}
