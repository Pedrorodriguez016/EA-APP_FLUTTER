import 'package:get/get.dart';
import '../Controllers/chat_list_controller.dart';
import '../Services/user_services.dart';
import '../Controllers/auth_controller.dart';

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserServices>(() => UserServices());
    Get.lazyPut<ChatListController>(() => ChatListController(
      Get.find<UserServices>(), 
      Get.find<AuthController>() 
    ));
  }
}