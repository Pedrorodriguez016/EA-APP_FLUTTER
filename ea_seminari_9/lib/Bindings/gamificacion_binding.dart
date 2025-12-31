import 'package:get/get.dart';
import '../Controllers/gamificacion_controller.dart';

class GamificacionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GamificacionController>(() => GamificacionController());
  }
}
