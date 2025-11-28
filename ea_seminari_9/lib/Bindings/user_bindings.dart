import '../Controllers/user_controller.dart';
import '../Services/user_services.dart';
import 'package:get/get.dart';
import '../Services/socket_services.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
     Get.lazyPut<UserServices>(() => UserServices());
     Get.lazyPut<SocketService>(() => SocketService());
     Get.lazyPut<UserController>(() => UserController(Get.find<UserServices>(), Get.find<SocketService>()));
  }
}