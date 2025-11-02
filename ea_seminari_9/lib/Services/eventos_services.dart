import 'package:get/get.dart';
import '../Models/eventos.dart';
import '../Controllers/eventos_controller.dart';

class EventosService extends GetxService {
  var events = <Evento>[].obs;
  var isLoading = false.obs;

  final EventosController _eventController = EventosController();

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      events.value = await _eventController.fetchEvents();
    } catch (e) {
      print('Error cargando eventos: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
