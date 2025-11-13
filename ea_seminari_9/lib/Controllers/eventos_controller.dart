import 'package:ea_seminari_9/Models/eventos.dart';
import 'package:ea_seminari_9/Services/eventos_services.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';

class EventoController extends GetxController {
  var isLoading = true.obs;
  var eventosList = <Evento>[].obs;
   var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalEventos = 0.obs;
  final int limit = 10;
  var searchQuery = ''.obs;
  var selectedEvento = Rxn<Evento>();
  final TextEditingController searchEditingController = TextEditingController();
 final EventosServices _eventosServices;

  EventoController(this._eventosServices);
  @override
  void onInit() {
    fetchEventos(1);
    super.onInit();
  }

  void fetchEventos(int page) async {
    isLoading.value = true;
    try {
      final data = await _eventosServices.fetchEvents(
        page: page,
        limit: limit,
        q: searchQuery.value,
      );

      eventosList.assignAll(data['eventos']);
      currentPage.value = data['currentPage'];
      totalPages.value = data['totalPages'];
      totalEventos.value = data['total'];
    } catch (e) {
      print("Error al cargar usuarios: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      fetchEventos(currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      fetchEventos(currentPage.value - 1);
    }
  }

  void searchEventos(String query) {
    searchQuery.value = query;
    fetchEventos(1);
  }
  void refreshEventos() {
    searchQuery.value = '';
    searchEditingController.clear(); 
    fetchEventos(1);
    Get.snackbar(
      'Actualizado',
      'Lista de Eventos actualizada',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  fetchEventoById(String id) async{
    try {
      isLoading(true);
      var evento = await _eventosServices.fetchEventById(id);
      selectedEvento.value = evento;
      }
      catch(e){
        Get.snackbar(
        "Error al cargar",
        "No se pudo encontrar el evento: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
}