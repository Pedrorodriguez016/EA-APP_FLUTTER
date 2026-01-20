import 'package:ea_seminari_9/Controllers/eventos_controller.dart';
import 'package:ea_seminari_9/Services/eventos_services.dart';
import 'package:ea_seminari_9/Services/socket_services.dart';
import 'package:get/get.dart';

class EventosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventosServices>(() => EventosServices());
    Get.lazyPut<SocketService>(() => SocketService());
    Get.lazyPut<EventoController>(
      () => EventoController(
        Get.find<EventosServices>(),
        Get.find<SocketService>(),
      ),
    );
  }
}
