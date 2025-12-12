import 'package:get/get.dart';
import '../Services/chatbot_service.dart';
import '../Controllers/chatbot_controller.dart';

class ChatBotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatBotService>(() => ChatBotService());
    Get.lazyPut<ChatBotController>(
      () => ChatBotController(Get.find<ChatBotService>()),
    );
  }
}
