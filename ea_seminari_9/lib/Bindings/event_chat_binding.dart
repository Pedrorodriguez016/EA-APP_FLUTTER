import 'package:get/get.dart';
import '../Controllers/event_chat_controller.dart';
import '../Controllers/auth_controller.dart';
import '../Services/socket_services.dart';

class EventChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => EventChatController(
        Get.find<SocketService>(),
        Get.find<AuthController>(),
      ),
    );
  }
}
