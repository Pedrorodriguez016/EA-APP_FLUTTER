import '../Controllers/user_controller.dart';
import '../Services/user_services.dart';
import '../Controllers/eventos_controller.dart';
import '../Services/eventos_services.dart';
import 'package:get/get.dart';
import '../Services/socket_services.dart';
import '../Controllers/notificacion_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserServices>(() => UserServices());
    Get.lazyPut<SocketService>(() => SocketService());
    Get.lazyPut<UserController>(
      () => UserController(Get.find<UserServices>(), Get.find<SocketService>()),
    );
    Get.lazyPut<EventosServices>(() => EventosServices());
    Get.put<EventoController>(
      EventoController(Get.find<EventosServices>()),
      permanent: true,
    );
    Get.put<NotificacionController>(NotificacionController(), permanent: true);
  }
}
