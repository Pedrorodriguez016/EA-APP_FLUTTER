import 'package:ea_seminari_9/Models/eventos.dart';
import 'package:ea_seminari_9/Services/eventos_services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EventoController extends GetxController {
  // --- Variables de la lista (existentes) ---
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

  // --- ARREGLO: Inicializa los controllers aquí ---
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  var selectedSchedule = Rxn<DateTime>();
  // --- FIN ARREGLO ---

  EventoController(this._eventosServices);

  @override
  void onInit() {
    fetchEventos(1); // Carga inicial de eventos
    selectedSchedule.value = null; // Limpia la fecha
    super.onInit();
  }

  // --- Limpia los campos del formulario ---
  void limpiarFormularioCrear() {
    tituloController.clear();
    direccionController.clear();
    selectedSchedule.value = null;
  }

  // --- Muestra el selector de fecha y hora ---
  Future<void> pickSchedule(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedSchedule.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (date == null) return; 

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedSchedule.value ?? DateTime.now()),
    );

    if (time == null) return; 

    final DateTime combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    selectedSchedule.value = combinedDateTime;
  }

  // --- (Funciones de la lista: fetchEventos, nextPage, etc.) ---
  
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
      print("Error al cargar eventos: $e");
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

  fetchEventoById(String id) async {
    try {
      isLoading(true);
      var evento = await _eventosServices.fetchEventById(id);
      selectedEvento.value = evento;
    } catch (e) {
      Get.snackbar(
        "Error al cargar",
        "No se pudo encontrar el evento: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
  
  // --- Función 'crearEvento' ---
  Future<void> crearEvento() async {
    final String titulo = tituloController.text;
    final String direccion = direccionController.text;

    // --- Validación ---
    if (titulo.isEmpty) {
      Get.snackbar('Campo requerido', 'Por favor, introduce un título.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    
    if (selectedSchedule.value == null) {
      Get.snackbar('Campo requerido', 'Por favor, selecciona una fecha y hora.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    // --- Fin Validación ---

    try {
      final Map<String, dynamic> nuevoEventoData = {
        'name': titulo,
        'address': direccion,
        'schedule': selectedSchedule.value!.toIso8601String(),
      };

      await _eventosServices.createEvento(nuevoEventoData);

      // 1. Volvemos al Home INMEDIATAMENTE
      Get.back();

      // 2. Limpiamos el formulario (para la próxima vez)
      limpiarFormularioCrear();

      // 3. Mostramos el mensaje de Éxito (se mostrará sobre el Home)
      Get.snackbar(
        'Éxito',
        'El evento "$titulo" se ha creado correctamente.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    // 4. Refrescamos la lista de eventos en el Home
      // (refreshEventos() ya muestra su propio snackbar,
      // quizás quieras quitar el de 'Éxito' si te molesta)
      refreshEventos();

    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el evento: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Limpia los controllers de texto
  @override
  void onClose() {
    tituloController.dispose();
    direccionController.dispose();
    super.onClose();
  }
}