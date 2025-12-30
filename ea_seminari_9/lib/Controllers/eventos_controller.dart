import 'package:ea_seminari_9/Models/eventos.dart';
import 'package:ea_seminari_9/Services/eventos_services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'auth_controller.dart';
import '../utils/logger.dart';
import 'package:latlong2/latlong.dart';
import 'auth_controller.dart';
import 'package:ea_seminari_9/Models/user.dart';
import 'package:ea_seminari_9/Services/user_services.dart';

// Definimos los tipos de filtro posibles
enum EventFilter { all, myEvents }

class EventoController extends GetxController {
  var isLoading = true.obs;
  var isMoreLoading = false.obs;
  var eventosList = <Evento>[].obs;
  var mapEventosList = <Evento>[].obs;
  var misEventosCreados = <Evento>[].obs;
  var misEventosInscritos = <Evento>[].obs;
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
  late TextEditingController tituloController;
  late TextEditingController direccionController;
  var selectedSchedule = Rxn<DateTime>();
  var selectedCategoria = Rxn<String>(); // Añadido para categoría
  var isPrivate = false.obs;
  var friendsList = <User>[].obs;
  var selectedInvitedUsers = <String>[].obs;
  var isLoadingFriends = false.obs;
  final UserServices _userServices = UserServices();

  EventoController(this._eventosServices);
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    tituloController = TextEditingController();
    direccionController = TextEditingController();

    // Inicializar datos
    selectedSchedule.value = null;
    fetchEventos(1);

    // Agregar listener una sola vez
    scrollController.addListener(_scrollListener);

    // Escucha el estado del usuario para refrescar la lista si es necesario.
    ever(_authController.currentUser, (user) {
      if (user != null) {
        refreshEventos();
      }
    });
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
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value &&
          !isMoreLoading.value &&
          currentPage.value < totalPages.value) {
        loadMoreEvents();
      }
    }
  }

  void setFilter(EventFilter filter) {
    if (currentFilter.value != filter) {
      currentFilter.value = filter;
      searchEditingController.clear();

      if (filter == EventFilter.myEvents) {
        eventosList.clear();
        fetchMisEventosEspecificos();
      } else {
        currentPage.value = 1;
        fetchEventos(1);
      }
    }
  }

  void fetchEventos(int page) async {
    String? creatorId;
    if (currentFilter.value == EventFilter.myEvents) {
      creatorId = _authController.currentUser.value?.id;
      logger.i('📄 Cargando mis eventos, creatorId: $creatorId');

      if (creatorId == null) {
        isLoading.value = false;
        isMoreLoading.value = false;
        eventosList.clear();
        logger.w('⚠️ Usuario no autenticado, no se pueden cargar eventos');

        // Esto evita que intente cargar eventos si el usuario no está logueado
        Get.snackbar(
          translate('events.errors.restricted_access_title'),
          translate('events.errors.restricted_access_msg'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
        return;
      }
    }

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
      if (page == 1) eventosList.clear();

      Get.snackbar(
        'Error de Carga',
        'No se pudieron cargar los eventos. Revise su conexión o el servidor.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void loadMoreEvents() {
    if (currentPage.value < totalPages.value) {
      fetchEventos(currentPage.value + 1);
    }
  }

  void limpiarFormularioCrear() {
    tituloController.clear();
    direccionController.clear();
    selectedSchedule.value = null;
    selectedCategoria.value = null;
    isPrivate.value = false;
    selectedInvitedUsers.clear();
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
      initialTime: TimeOfDay.fromDateTime(
        selectedSchedule.value ?? DateTime.now(),
      ),
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

  void fetchMapEvents(
    double north,
    double south,
    double east,
    double west,
  ) async {
    try {
      logger.d(
        '🗺️ Cargando eventos del mapa - Bounds: N:$north S:$south E:$east W:$west',
      );
      var nuevosEventos = await _eventosServices.fetchEventsByBounds(
        north: north,
        south: south,
        east: east,
        west: west,
      );
      mapEventosList.assignAll(nuevosEventos);
    } catch (e) {
      logger.e('❌ Error cargando mapa', error: e);
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

      final Evento? evento = await _eventosServices.getEventoByName(
        searchEditingController.text,
      );

      if (evento != null) {
        eventosList.assignAll([evento]);
      } else {
        eventosList.clear();
        Get.snackbar(
          translate('common.search'),
          translate('events.empty_search'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void refreshEventos() {
    searchEditingController.clear();
    fetchEventos(1);
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
        translate('events.errors.title_required'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedSchedule.value == null) {
      Get.snackbar(
        translate('common.error'),
        translate('events.errors.date_required'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedCategoria.value == null) {
      Get.snackbar(
        translate('common.error'),
        translate('events.errors.category_required'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final Map<String, dynamic> nuevoEventoData = {
        'name': titulo,
        'address': direccion,
        'schedule': selectedSchedule.value!.toIso8601String(),
        'categoria': selectedCategoria.value!, // Enviar categoría seleccionada
        'isPrivate': isPrivate.value,
        'invitados': selectedInvitedUsers.toList(),
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
      fetchMapEvents(bounds.north, bounds.south, bounds.east, bounds.west);
    });
  }

  Future<void> toggleParticipation() async {
    final user = _authController.currentUser.value;
    final event = selectedEvento.value;

    if (user == null || event == null) {
      Get.snackbar(
        translate('common.error'),
        translate('events.errors.login_to_participate'),
      );
      return;
    }

    final isParticipant = event.participantes.contains(user.id);

    try {
      isLoading(true);

      Evento updatedEvento;

      if (isParticipant) {
        updatedEvento = await _eventosServices.leaveEvent(event.id);
        Get.snackbar(
          translate('common.success'),
          translate('events.left_success'),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        updatedEvento = await _eventosServices.joinEvent(event.id);
        Get.snackbar(
          translate('common.success'),
          translate('events.joined_success'),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      selectedEvento.value = updatedEvento;

      final index = eventosList.indexWhere((e) => e.id == updatedEvento.id);
      if (index != -1) {
        eventosList[index] = updatedEvento;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void fetchMisEventosEspecificos() async {
    try {
      isLoading(true);
      final resultado = await _eventosServices.getMisEventos();
      misEventosCreados.assignAll(resultado['creados']!);
      misEventosInscritos.assignAll(resultado['inscritos']!);
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        translate('events.errors.load_my_events'),
      );
    } finally {
      isLoading(false);
    }
  }

  void fetchFriends() async {
    final userId = _authController.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoadingFriends(true);
      final friends = await _userServices.fetchFriends(userId);
      friendsList.assignAll(friends);
    } catch (e) {
      print("Error fetching friends: $e");
    } finally {
      isLoadingFriends(false);
    }
  }

  void toggleUserSelection(String userId) {
    if (selectedInvitedUsers.contains(userId)) {
      selectedInvitedUsers.remove(userId);
    } else {
      selectedInvitedUsers.add(userId);
    }
  }

  Future<void> respondToInvitation(bool accept) async {
    final event = selectedEvento.value;
    if (event == null) return;

    try {
      isLoading(true);
      Evento updatedEvento;

      if (accept) {
        updatedEvento = await _eventosServices.acceptInvitation(event.id);
        Get.snackbar(
          "Éxito",
          "Invitación aceptada",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        updatedEvento = await _eventosServices.rejectInvitation(event.id);
        Get.snackbar(
          "Información",
          "Invitación rechazada",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

      selectedEvento.value = updatedEvento;

      final index = eventosList.indexWhere((e) => e.id == updatedEvento.id);
      if (index != -1) {
        eventosList[index] = updatedEvento;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}
