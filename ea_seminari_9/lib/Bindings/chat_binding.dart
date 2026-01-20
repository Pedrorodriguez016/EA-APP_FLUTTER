import 'package:ea_seminari_9/Controllers/auth_controller.dart';
import 'package:ea_seminari_9/Services/socket_services.dart';
import 'package:get/get.dart';
import '../Controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocketService>(() => SocketService());
    Get.lazyPut<ChatController>(
      () =>
          ChatController(Get.find<SocketService>(), Get.find<AuthController>()),
    );
  }
}
