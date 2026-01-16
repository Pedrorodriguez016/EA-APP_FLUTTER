import 'package:get/get.dart';
import '../Controllers/event_chat_controller.dart';
import '../Controllers/auth_controller.dart';
import '../Services/socket_services.dart';
import '../Services/eventos_services.dart';

class EventChatBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EventosServices>()) {
      Get.lazyPut(() => EventosServices());
    }
    Get.lazyPut(
      () => EventChatController(
        Get.find<SocketService>(),
        Get.find<AuthController>(),
      ),
    );
  }
}
