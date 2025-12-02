import 'package:ea_seminari_9/Models/eventos.dart';
import 'package:ea_seminari_9/Services/eventos_services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'auth_controller.dart'; 

// Definimos los tipos de filtro posibles
enum EventFilter { all, myEvents }

class EventoController extends GetxController {
  // --- Variables de la lista ---
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

  // --- ESTADOS PARA FILTRADO ---
  var currentFilter = EventFilter.all.obs; 
  final AuthController _authController = Get.find<AuthController>(); 

  // --- Controllers para formulario ---
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  var selectedSchedule = Rxn<DateTime>();

  EventoController(this._eventosServices);
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    // Escucha el estado del usuario para refrescar la lista si es necesario.
    ever(_authController.currentUser, (_) {
      if (currentFilter.value == EventFilter.myEvents || _authController.currentUser.value == null) {
        refreshEventos();
      }
    });
    
    fetchEventos(1); 
    selectedSchedule.value = null; 
    super.onInit();
    scrollController.addListener(_scrollListener);
  }
  
  @override
  void onClose() {
    tituloController.dispose();
    direccionController.dispose();
    _debounce?.cancel();
    scrollController.removeListener(_scrollListener); 
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && !isMoreLoading.value && currentPage.value < totalPages.value) {
        loadMoreEvents();
      }
    }
  }

  void setFilter(EventFilter filter) {
    if (currentFilter.value != filter) {
      currentFilter.value = filter;
      currentPage.value = 1; 
      eventosList.clear(); 
      searchEditingController.clear(); 
      fetchEventos(1);
    }
  }


  void fetchEventos(int page) async {
    
    String? creatorId;
    if (currentFilter.value == EventFilter.myEvents) {
      creatorId = _authController.currentUser.value?.id; 
      
      if (creatorId == null) {
        isLoading.value = false;
        isMoreLoading.value = false;
        eventosList.clear(); 
        
        // Esto evita que intente cargar eventos si el usuario no está logueado
        Get.snackbar('Acceso Restringido', 'Debes iniciar sesión para ver tus eventos.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        return;
      }
    }

    // --- LÍNEA DE DEPURACIÓN CLAVE ---
    // Mira esta línea en la consola para saber si tienes el ID del usuario.
    print("DEBUG FILTRO: Filtro actual: ${currentFilter.value.name}, creatorId enviado: $creatorId");
    // ----------------------------------

    if (page == 1) {  
      isLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }
    

    try {
      final data = await _eventosServices.fetchEvents(
        page: page,
        limit: limit,
        creatorId: creatorId, 
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
      if (page == 1) eventosList.clear();
      
      Get.snackbar('Error de Carga', 'No se pudieron cargar los eventos. Revise su conexión o el servidor.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);

    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }
  
  // --- [Resto de las funciones sin cambios, solo para completar el archivo] ---

  void loadMoreEvents() { 
    if (currentPage.value < totalPages.value) {
       fetchEventos(currentPage.value + 1); 
    }
  }
  
  void limpiarFormularioCrear() {
    tituloController.clear();
    direccionController.clear();
    selectedSchedule.value = null;
  }

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
  
  Future<void> crearEvento() async {
    final String titulo = tituloController.text;
    final String direccion = direccionController.text;

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

    try {
      final Map<String, dynamic> nuevoEventoData = {
        'name': titulo,
        'address': direccion,
        'schedule': selectedSchedule.value!.toIso8601String(),
      };

      await _eventosServices.createEvento(nuevoEventoData);

      Get.back();
      limpiarFormularioCrear();

      Get.snackbar(
        'Éxito',
        'El evento "$titulo" se ha creado correctamente.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    
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

  Future<void> toggleParticipation() async {
    final user = _authController.currentUser.value;
    final event = selectedEvento.value;

    if (user == null || event == null) {
      Get.snackbar('Error', 'Debes iniciar sesión para participar');
      return;
    }

    final isParticipant = event.participantes.contains(user.id);

    try {
      isLoading(true); 
      
      Evento updatedEvento;

      if (isParticipant) {
        // Salir: Backend devuelve el evento sin el usuario
        updatedEvento = await _eventosServices.leaveEvent(event.id);
        Get.snackbar(
          "Existo!", 
          "Has salido del evento", 
          backgroundColor: Colors.orange, 
          colorText: Colors.white
        );
      } else {
        // Unirse: Backend devuelve el evento con el usuario añadido
        updatedEvento = await _eventosServices.joinEvent(event.id);
        Get.snackbar(
          "Exito!", 
          "Te has unido al evento", 
          backgroundColor: Colors.green, 
          colorText: Colors.white
        );
      }

      // ACTUALIZACIÓN CLAVE: Reemplazamos el objeto local con el que vino del servidor
      selectedEvento.value = updatedEvento;
      
      // También actualizamos la lista general si es necesario para que se refleje al volver atrás
      final index = eventosList.indexWhere((e) => e.id == updatedEvento.id);
      if (index != -1) {
        eventosList[index] = updatedEvento;
      }

    } catch (e) {
      Get.snackbar(
       "Error",
        e.toString(), // O un mensaje más amigable
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}