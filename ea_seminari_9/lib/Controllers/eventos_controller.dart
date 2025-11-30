import 'package:ea_seminari_9/Models/eventos.dart';
import 'package:ea_seminari_9/Services/eventos_services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'auth_controller.dart'; // ¡IMPORTANTE! Asumo que tienes este archivo

// Definimos los tipos de filtro posibles
enum EventFilter { all, myEvents }

class EventoController extends GetxController {
  // --- Variables de la lista (existentes) ---
  var isLoading = true.obs;
  var isMoreLoading = false.obs;
  var eventosList = <Evento>[].obs;
  var mapEventosList = <Evento>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalEventos = 0.obs;
  final int limit = 10;
  var selectedEvento = Rxn<Evento>();
  final TextEditingController searchEditingController = TextEditingController();
  final EventosServices _eventosServices;
  Timer? _debounce;

  // --- NUEVOS ESTADOS PARA FILTRADO ---
  var currentFilter = EventFilter.all.obs; // Estado del filtro actual
  final AuthController _authController = Get.find<AuthController>(); // Inyectamos AuthController

  // --- ARREGLO: Inicializa los controllers aquí ---
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  var selectedSchedule = Rxn<DateTime>();
  // --- FIN ARREGLO ---

  EventoController(this._eventosServices);
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    fetchEventos(1); // Carga inicial de eventos
    selectedSchedule.value = null; // Limpia la fecha
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoading.value && !isMoreLoading.value && currentPage.value < totalPages.value) {
          loadMoreEvents();
        }
      }
    });
  }

  // Nuevo método para cambiar el filtro y reiniciar la lista (página 1)
  void setFilter(EventFilter filter) {
    if (currentFilter.value != filter) {
      currentFilter.value = filter;
      refreshEventos(); // Llama a refreshEventos, que a su vez llama a fetchEventos(1)
    }
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

 void fetchMapEvents(double north, double south, double east, double west) async {
    try {
      // Llamada al servicio
      var nuevosEventos = await _eventosServices.fetchEventsByBounds(
        north: north, 
        south: south, 
        east: east, 
        west: west
      );
      
      mapEventosList.assignAll(nuevosEventos);
      
    } catch (e) {
      print("Error cargando mapa: $e");
    }
  }




  
  void fetchEventos(int page) async {
    // 1. Determinar el creatorId si el filtro es "Mis Eventos"
    String? creatorId;
    if (currentFilter.value == EventFilter.myEvents) {
      // Usar el ID del usuario logueado.
      // ¡ATENCIÓN! Asegúrate de que 'user.value?.id' sea la propiedad correcta
      creatorId = _authController.currentUser.value?.id; 
      
      if (creatorId == null) {
        // Si no hay ID de usuario logueado, no podemos cargar "Mis Eventos"
        isLoading.value = false;
        isMoreLoading.value = false;
        eventosList.clear();
        Get.snackbar('Error de Acceso', 'Debes iniciar sesión para ver tus eventos.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        return;
      }
    }

     // 2. Control de estado de carga
    if (page == 1) {  
      isLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }
    

    try {
      // 3. Llamada al servicio con el creatorId (que será null para 'EventFilter.all')
      final data = await _eventosServices.fetchEvents(
        page: page,
        limit: limit,
        creatorId: creatorId, // <-- PASAMOS EL FILTRO AL SERVICIO
      );
        
      final List<Evento> newEventos = data['eventos'];
      if (page == 1) {
        eventosList.assignAll(newEventos);
      } else {
        eventosList.addAll(newEventos);
      }
      currentPage.value = data['currentPage'];
      totalPages.value = data['totalPages'];
      totalEventos.value = data['total'];
      } catch (e) {
      print("Error al cargar eventos: $e");
      // En caso de error, limpiamos la lista
      if (page == 1) eventosList.clear();
      } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
      }
 }

  void loadMoreEvents() { // Renombré loadMoreUsers por loadMoreEvents
  if (currentPage.value < totalPages.value) {
       fetchEventos(currentPage.value + 1); 
    }
  }

  Future<void> searchEventos(String query) async {
    if (searchEditingController.text.isEmpty) {
      refreshEventos();
      return;
    }

    try {
      isLoading(true);
    
      final Evento? evento = await _eventosServices.getEventoByName(searchEditingController.text);
      if (evento != null) {
        eventosList.assignAll([evento]);
      } else {
        eventosList.clear();
        Get.snackbar(
          'Búsqueda', 
          'No se encontró ningún evento con ese nombre',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2)
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Ocurrió un error al buscar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
    } finally {
      isLoading(false);
    }
  }

  void refreshEventos() {
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
  
 void onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      
      final bounds = camera.visibleBounds;
      
      fetchMapEvents(
        bounds.north, 
        bounds.south, 
        bounds.east, 
        bounds.west
      );
    });
  }
  
  // Limpia los controllers de texto
  @override
  void onClose() {
    tituloController.dispose();
    direccionController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
  
}