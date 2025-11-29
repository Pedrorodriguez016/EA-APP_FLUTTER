import 'package:ea_seminari_9/Models/eventos.dart';
import 'package:ea_seminari_9/Services/eventos_services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar

class EventoController extends GetxController {
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

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  var selectedSchedule = Rxn<DateTime>();

  EventoController(this._eventosServices);
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    fetchEventos(1);
    selectedSchedule.value = null;
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoading.value && !isMoreLoading.value && currentPage.value < totalPages.value) {
          loadMoreUsers();
        }
      }
    });
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

  void fetchEventos(int page) async {
    if (page == 1) {
      isLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }
    try {
      final data = await _eventosServices.fetchEvents(
        page: page,
        limit: limit,
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
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void loadMoreUsers() {
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
          translate('common.search'), // 'Búsqueda'
          translate('events.empty_search'), // 'No se encontró ningún evento...'
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2)
        );
      }
    } catch (e) {
      Get.snackbar(
        translate('common.error'), 
        e.toString(),
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
      translate('common.update'), // 'Actualizado'
      translate('events.list_updated') ?? 'Lista de Eventos actualizada', // Asegúrate de tener esta clave o pon el texto traducido aquí
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
        translate('common.error'),
        translate('events.not_found'),
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
      Get.snackbar(
          translate('common.error'), 
          translate('events.errors.title_required') ?? 'Por favor, introduce un título.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    
    if (selectedSchedule.value == null) {
      Get.snackbar(
          translate('common.error'), 
          translate('events.errors.date_required') ?? 'Por favor, selecciona una fecha.',
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
        translate('common.success'),
        translate('events.created_success'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      refreshEventos();

    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
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
  
  @override
  void onClose() {
    tituloController.dispose();
    direccionController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}