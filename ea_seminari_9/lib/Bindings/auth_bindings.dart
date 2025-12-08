import 'package:get/get.dart';
import '../Controllers/auth_controller.dart';
import '../Services/auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}