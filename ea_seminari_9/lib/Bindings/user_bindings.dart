import '../Controllers/user_controller.dart';
import '../Services/user_services.dart';
import 'package:get/get.dart';
import '../Services/socket_services.dart';
import '../Controllers/eventos_controller.dart';
import '../Services/eventos_services.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserServices>(UserServices());
    Get.put<SocketService>(SocketService());
    Get.put<UserController>(
      UserController(Get.find<UserServices>(), Get.find<SocketService>()),
    );
    Get.put<EventoController>(EventoController(EventosServices()));
  }
}
