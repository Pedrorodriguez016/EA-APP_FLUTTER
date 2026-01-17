import 'package:get/get.dart';
import '../Controllers/event_chat_controller.dart';
import '../Controllers/auth_controller.dart';
import '../Services/socket_services.dart';
import '../Services/eventos_services.dart';
import '../Services/user_services.dart';
import '../Controllers/user_controller.dart';

class EventChatBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EventosServices>()) {
      Get.lazyPut(() => EventosServices());
    }
    if (!Get.isRegistered<UserServices>()) {
      Get.lazyPut(() => UserServices());
    }
    if (!Get.isRegistered<UserController>()) {
      Get.lazyPut(
        () =>
            UserController(Get.find<UserServices>(), Get.find<SocketService>()),
      );
    }
    Get.lazyPut(
      () => EventChatController(
        Get.find<SocketService>(),
        Get.find<AuthController>(),
      ),
    );
  }
}
