import 'package:ea_seminari_9/Models/eventos.dart';
import 'package:ea_seminari_9/Services/eventos_services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'auth_controller.dart';
import '../utils/logger.dart';
import 'package:ea_seminari_9/Models/user.dart';
import 'package:ea_seminari_9/Services/user_services.dart';
import 'package:ea_seminari_9/Services/socket_services.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ea_seminari_9/Models/evento_photo.dart';
import 'package:image_picker/image_picker.dart';

enum EventFilter { all, myEvents, recommended }

class EventoController extends GetxController {
  var isLoading = true.obs;
  var isMoreLoading = false.obs;
  var eventosList = <Evento>[].obs;
  var mapEventosList = <Evento>[].obs;
  var misEventosCreados = <Evento>[].obs;
  var misEventosInscritos = <Evento>[].obs;
  var calendarEvents = <Evento>[].obs;
  var selectedDayEvents = <Evento>[].obs;
  var recommendedEventos = <Evento>[].obs;
  var isCalendarView = false.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalEventos = 0.obs;
  var isSearching = false.obs;
  var misInvitaciones = <Evento>[].obs;

  // Fotos del evento
  var eventoPhotos = <EventoPhoto>[].obs;
  var isPhotosLoading = false.obs;

  // Paginación para Recomendados
  var currentRecommendedPage = 1.obs;
  var hasMoreRecommended = true.obs;
  var isRecommendedLoadingMore = false.obs;

  var filterCategory = Rxn<String>(); // Category filter
  var filterDateFrom = Rxn<DateTime>(); // Date range start
  var filterDateTo = Rxn<DateTime>(); // Date range end
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
  late TextEditingController capacidadMaximaController;
  var selectedSchedule = Rxn<DateTime>();
  var selectedCategoria = Rxn<String>(); // Añadido para categoría
  var selectedLat = Rxn<double>(); // Coordenadas de la dirección seleccionada
  var selectedLon = Rxn<double>();
  var isPrivate = false.obs;
  var friendsList = <User>[].obs;
  var selectedInvitedUsers = <String>[].obs;
  var isLoadingFriends = false.obs;

  // --- MODO EDICIÓN ---
  var isEditing = false.obs;
  var editingEventoId = Rxn<String>();
  final UserServices _userServices = UserServices();
  final SocketService _socketService;
  var userLocation = Rxn<LatLng>();
  var isLoadingLocation = false.obs;
  // Barcelona como ubicación por defecto
  final LatLng defaultLocation = const LatLng(41.3851, 2.1734);

  EventoController(this._eventosServices, this._socketService);
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    tituloController = TextEditingController();
    direccionController = TextEditingController();
    capacidadMaximaController = TextEditingController();
    selectedSchedule.value = null;
    fetchEventos(1);
    fetchRecommended();
    fetchPendingInvitations();
    _getUserLocation();
    scrollController.addListener(_scrollListener);

    // Registrar listener de invitaciones después de un pequeño delay
    // para asegurar que el socket esté conectado
    Future.delayed(const Duration(milliseconds: 500), () {
      _initSocketConnection();
    });

    ever(_authController.currentUser, (user) {
      if (user != null) {
        refreshEventos();
        // Re-inicializar socket cuando cambia el usuario
        Future.delayed(const Duration(milliseconds: 500), () {
          _initSocketConnection();
        });
      }
    });
  }

  void _initSocketConnection() {
    final userId = _authController.currentUser.value?.id;

    if (userId != null && userId.isNotEmpty) {
      logger.i(
        '🔌 [EventoController] Inicializando conexión Socket para invitaciones de eventos - User: $userId',
      );

      // Detener cualquier listener anterior para evitar duplicados
      _socketService.stopListeningToEventInvitations();

      // Escuchar invitaciones a eventos en tiempo real
      _socketService.listenToEventInvitations((data) {
        logger.i(
          '📨 [EventoController] Invitación a evento recibida por socket: $data',
        );
        try {
          final eventId = data['eventId'] as String?;
          final eventName = data['eventName'] as String?;
          final fromUsername = data['fromUsername'] as String?;

          if (eventName == null || fromUsername == null) {
            logger.w('⚠️ [EventoController] Datos incompletos en invitación');
            return;
          }

          logger.i(
            '✅ [EventoController] Procesando invitación: $fromUsername invitó a "$eventName"',
          );

          // Refrescar la lista de invitaciones
          fetchPendingInvitations();

          // Mostrar notificación al usuario
          Get.snackbar(
            translate('common.new_notification'),
            '$fromUsername ${translate('events.invited_you_to')} "$eventName"',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
        } catch (e) {
          logger.e(
            '[EventoController] Error procesando invitación a evento por socket',
            error: e,
          );
        }
      });

      logger.i(
        '✅ [EventoController] Listener de invitaciones registrado correctamente',
      );
    } else {
      logger.w(
        '⚠️ [EventoController] No se puede inicializar socket: userId no disponible',
      );
    }
  }

  @override
  void onClose() {
    tituloController.dispose();
    direccionController.dispose();
    capacidadMaximaController.dispose();
    _debounce?.cancel();
    scrollController.removeListener(_scrollListener);
    _socketService.stopListeningToEventInvitations();
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
      } else if (filter == EventFilter.recommended) {
        // Clear list and show recommended
        fetchRecommended(isRefresh: true);
        eventosList.assignAll(recommendedEventos);
      } else {
        currentPage.value = 1;
        fetchEventos(1);
      }
    }
  }

  Future<void> fetchEventos(int page, {String? category}) async {
    if (page == 1) {
      isLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }

    try {
      final String searchText = searchEditingController.text.trim();
      Map<String, dynamic> data;

      // La categoría puede venir del parámetro o del estado reactivo del filtro
      final String? selectedCat = category ?? filterCategory.value;

      // Si estamos en modo recomendados, cargamos recomendaciones
      if (currentFilter.value == EventFilter.recommended) {
        final recEvents = await _eventosServices.fetchRecommendedEvents(
          page: page,
          limit: limit,
        );
        data = {
          'eventos': recEvents,
          'currentPage': page,
          'totalPages':
              1, // Recomendaciones suelen ser limitadas o paginadas distinto
          'total': recEvents.length,
        };
      }
      // Si hay búsqueda por texto, categoría o fechas, usamos el endpoint /search
      else if (searchText.isNotEmpty ||
          (selectedCat != null && selectedCat.isNotEmpty) ||
          filterDateFrom.value != null ||
          filterDateTo.value != null) {
        data = await _eventosServices.searchEvents(
          page: page,
          limit: limit,
          search: searchText.isNotEmpty ? searchText : null,
          category: selectedCat,
          dateFrom: filterDateFrom.value != null
              ? "${filterDateFrom.value!.year}-${filterDateFrom.value!.month.toString().padLeft(2, '0')}-${filterDateFrom.value!.day.toString().padLeft(2, '0')}"
              : null,
          dateTo: filterDateTo.value != null
              ? "${filterDateTo.value!.year}-${filterDateTo.value!.month.toString().padLeft(2, '0')}-${filterDateTo.value!.day.toString().padLeft(2, '0')}"
              : null,
        );
      } else {
        // Si no hay ningún filtro, usamos el /visible normal
        data = await _eventosServices.fetchEvents(page: page, limit: limit);
      }

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

  void clearFilters() {
    filterDateFrom.value = null;
    filterDateTo.value = null;
    filterCategory.value = null;
    currentFilter.value = EventFilter.all;
    searchEditingController.clear();
    isSearching.value = false;
    fetchEventos(1);
  }

  void searchEventos(String query) {
    // Alias to trigger a search from the UI
    isSearching.value = query.isNotEmpty;
    fetchEventos(1);
  }

  int getEventCountForCategory(String category) {
    // Current count based on loaded events or we could fetch specifically
    return eventosList.where((e) => e.categoria == category).length;
  }

  void loadMoreEvents() {
    if (currentPage.value < totalPages.value) {
      fetchEventos(currentPage.value + 1);
    }
  }

  // --- Obtener ubicación del usuario ---
  Future<void> _getUserLocation() async {
    isLoadingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w('Servicio de ubicación deshabilitado');
        userLocation.value = defaultLocation;
        isLoadingLocation.value = false;
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.w('Permisos de ubicación denegados');
          userLocation.value = defaultLocation;
          isLoadingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.w('Permisos de ubicación denegados permanentemente');
        userLocation.value = defaultLocation;
        isLoadingLocation.value = false;
        return;
      }

      // Obtener la posición actual
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      userLocation.value = LatLng(position.latitude, position.longitude);
      logger.i(
        'Ubicación del usuario: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      logger.e('Error obteniendo ubicación: $e');
      userLocation.value = defaultLocation;
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // --- Limpia los campos del formulario ---
  void limpiarFormularioCrear() {
    tituloController.clear();
    direccionController.clear();
    capacidadMaximaController.clear();
    selectedSchedule.value = null;
    selectedCategoria.value = null;
    selectedLat.value = null;
    selectedLon.value = null;
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
    if (!context.mounted) return;

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

  Future<void> refreshEventos() async {
    searchEditingController.clear();
    await fetchEventos(1);
    await fetchRecommended(isRefresh: true);
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      fetchEventos(currentPage.value + 1);
    }
  }

  fetchEventoById(String id) async {
    try {
      isLoading(true);
      var evento = await _eventosServices.fetchEventById(id);
      selectedEvento.value = evento;
      _updateEventInLists(evento);
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

    // Validar capacidad máxima si el usuario ingresó algo
    final capacidadText = capacidadMaximaController.text.trim();
    if (capacidadText.isNotEmpty) {
      final capacidad = int.tryParse(capacidadText);
      if (capacidad == null || capacidad <= 0) {
        Get.snackbar(
          'Valor inválido',
          'La capacidad máxima debe ser un número mayor a 0.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
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

      // Agregar coordenadas si están disponibles
      if (selectedLat.value != null && selectedLon.value != null) {
        nuevoEventoData['lat'] = selectedLat.value;
        nuevoEventoData['lng'] = selectedLon.value;
      }

      // Agregar capacidad máxima solo si el usuario ingresó un valor
      if (capacidadText.isNotEmpty) {
        nuevoEventoData['maxParticipantes'] = int.parse(capacidadText);
      }
      // Si no ingresó nada, el evento tendrá capacidad ilimitada

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

  void cargarEventoParaEditar(Evento evento) {
    isEditing.value = true;
    editingEventoId.value = evento.id;

    tituloController.text = evento.name;
    direccionController.text = evento.address;
    capacidadMaximaController.text = evento.capacidadMaxima != null
        ? evento.capacidadMaxima.toString()
        : '';

    if (evento.schedule.isNotEmpty) {
      try {
        selectedSchedule.value = DateTime.parse(evento.schedule);
      } catch (e) {
        logger.w('Error al parsear fecha del evento: ${evento.schedule}');
      }
    }

    selectedCategoria.value = evento.categoria;
    isPrivate.value = evento.isPrivate;

    // Poblar usuarios invitados si es privado
    selectedInvitedUsers.assignAll(evento.invitacionesPendientes);

    Get.toNamed('/crear_evento');
  }

  Future<void> actualizarEvento() async {
    final String id = editingEventoId.value!;
    final String titulo = tituloController.text;
    final String direccion = direccionController.text;
    final capacidadText = capacidadMaximaController.text.trim();

    if (titulo.isEmpty ||
        selectedSchedule.value == null ||
        selectedCategoria.value == null) {
      Get.snackbar(
        translate('common.error'),
        'Por favor, completa los campos obligatorios.',
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      final Map<String, dynamic> updateData = {
        'name': titulo,
        'address': direccion,
        'schedule': selectedSchedule.value!.toIso8601String(),
        'categoria': selectedCategoria.value!,
        'isPrivate': isPrivate.value,
        'invitados': selectedInvitedUsers.toList(),
      };

      if (capacidadText.isNotEmpty) {
        updateData['maxParticipantes'] = int.parse(capacidadText);
      } else {
        updateData['maxParticipantes'] = null;
      }

      final updatedEvento = await _eventosServices.updateEvento(id, updateData);

      Get.back();
      limpiarFormularioCrear();
      isEditing.value = false;
      editingEventoId.value = null;

      Get.snackbar(
        translate('common.success'),
        'Evento actualizado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _updateEventInLists(updatedEvento);
      fetchMisEventosEspecificos(); // Recargar mis eventos creados
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> eliminarEvento(String id) async {
    try {
      await _eventosServices.deleteEvento(id);
      eventosList.removeWhere((e) => e.id == id);
      misEventosCreados.removeWhere((e) => e.id == id);

      Get.snackbar(
        'Eliminado',
        'El evento ha sido eliminado',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar el evento');
    }
  }

  // Versión con debounce de fetchMapEvents para evitar peticiones masivas
  void fetchMapEventsDebounced(LatLngBounds bounds) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 1), () {
      fetchMapEvents(bounds.north, bounds.south, bounds.east, bounds.west);
    });
  }

  void onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final bounds = camera.visibleBounds;

      fetchMapEventsDebounced(bounds);
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

    final bool isParticipant = event.participantes.any((p) {
      if (user.id.isEmpty) return false;
      return p.trim() == user.id.trim();
    });
    final bool isOnWaitlist = event.listaEspera.any((p) {
      if (user.id.isEmpty) return false;
      return p.trim() == user.id.trim();
    });

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
      } else if (isOnWaitlist) {
        // Usar leaveWaitlist específicamente para lista de espera
        updatedEvento = await _eventosServices.leaveWaitlist(event.id);
        Get.snackbar(
          translate('common.success'),
          translate('events.left_waitlist'),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        final response = await _eventosServices.joinEvent(event.id);
        updatedEvento = response['evento'] as Evento;
        final enListaEspera = response['enListaEspera'] as bool;
        final mensaje = response['mensaje'] as String;

        // Mostrar el mensaje del backend
        Get.snackbar(
          enListaEspera ? 'En lista de espera' : 'Éxito!',
          mensaje,
          backgroundColor: enListaEspera ? Colors.orange : Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: enListaEspera ? 4 : 3),
        );
      }

      selectedEvento.value = updatedEvento;
      selectedEvento.refresh();

      // Sincronizar en todas las listas reactivas
      _updateEventInLists(updatedEvento);
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

  void _updateEventInLists(Evento updatedEvento) {
    final updatedId = updatedEvento.id.trim();
    logger.d(
      '🔄 Actualizando evento en listas: $updatedId (Participantes: ${updatedEvento.participantes.length})',
    );

    void updateSpecificList(RxList<Evento> list, String listName) {
      final index = list.indexWhere((e) => e.id.trim() == updatedId);
      if (index != -1) {
        list[index] = updatedEvento;
        list.refresh();
        logger.d('✅ Evento actualizado en $listName en el índice $index');
      }
    }

    updateSpecificList(eventosList, 'eventosList');
    updateSpecificList(calendarEvents, 'calendarEvents');
    updateSpecificList(selectedDayEvents, 'selectedDayEvents');
    updateSpecificList(mapEventosList, 'mapEventosList');
    updateSpecificList(recommendedEventos, 'recommendedEventos');
    updateSpecificList(misEventosCreados, 'misEventosCreados');
    updateSpecificList(misEventosInscritos, 'misEventosInscritos');
    updateSpecificList(misInvitaciones, 'misInvitaciones');

    if (selectedEvento.value?.id.trim() == updatedId) {
      selectedEvento.value = updatedEvento;
      logger.d('✅ selectedEvento actualizado');
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
      final friendsData = await _userServices.fetchFriends(userId);
      final List<User> friends = friendsData['friends'];
      friendsList.assignAll(friends);
    } catch (e) {
      logger.e('Error fetching friends: $e');
    } finally {
      isLoadingFriends(false);
    }
  }

  Future<void> fetchEventPhotos(String eventId) async {
    try {
      isPhotosLoading(true);
      final photos = await _eventosServices.fetchEventPhotos(eventId);
      eventoPhotos.assignAll(photos);
    } catch (e) {
      logger.e('Error fetching event photos: $e');
    } finally {
      isPhotosLoading(false);
    }
  }

  Future<void> uploadEventPhoto(String eventId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      isLoading(true);
      final newPhoto = await _eventosServices.uploadMedia(eventId, image.path);
      eventoPhotos.insert(0, newPhoto);

      Get.snackbar(
        '¡Éxito!',
        'Contenido compartido correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      logger.e('Error uploading photo: $e');
      Get.snackbar(
        'Error',
        'No se pudo compartir la foto',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void toggleUserSelection(String userId) {
    if (selectedInvitedUsers.contains(userId)) {
      selectedInvitedUsers.remove(userId);
    } else {
      selectedInvitedUsers.add(userId);
    }
  }

  Future<void> respondToInvitation(Evento? event, bool accept) async {
    final eventToUse = event ?? selectedEvento.value;
    if (eventToUse == null) return;

    try {
      isLoading(true);
      Evento updatedEvento;

      if (accept) {
        updatedEvento = await _eventosServices.acceptInvitation(eventToUse.id);
        Get.snackbar(
          'Éxito',
          'Invitación aceptada',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        updatedEvento = await _eventosServices.rejectInvitation(eventToUse.id);
        Get.snackbar(
          'Información',
          'Invitación rechazada',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

      if (event == null) {
        selectedEvento.value = updatedEvento;
      }

      // Quitar de la lista de invitaciones si estaba allí
      misInvitaciones.removeWhere((e) => e.id == eventToUse.id);

      _updateEventInLists(updatedEvento);
      fetchPendingInvitations(); // Recargar para estar seguros
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingInvitations() async {
    try {
      logger.i('📥 [EventoController] Obteniendo invitaciones pendientes...');
      final invitaciones = await _eventosServices.fetchPendingInvitations();
      logger.i(
        '✅ [EventoController] Invitaciones recibidas: ${invitaciones.length}',
      );

      if (invitaciones.isNotEmpty) {
        for (var inv in invitaciones) {
          logger.d('   - ${inv.name} (ID: ${inv.id})');
        }
      }

      misInvitaciones.assignAll(invitaciones);
      logger.i(
        '✅ [EventoController] misInvitaciones actualizado: ${misInvitaciones.length}',
      );
    } catch (e) {
      logger.e(
        '❌ [EventoController] Error fetching pending invitations',
        error: e,
      );
    }
  }

  Future<void> showFilterSheet(BuildContext context) async {
    final List<String> allCategories = [
      'Fútbol',
      'Baloncesto',
      'Tenis',
      'Pádel',
      'Running',
      'Ciclismo',
      'Natación',
      'Yoga',
      'Gimnasio',
      'Senderismo',
      'Escalada',
      'Artes Marciales',
      'Concierto Rock',
      'Concierto Pop',
      'Concierto Clásica',
      'Jazz',
      'Electrónica',
      'Hip Hop',
      'Karaoke',
      'Discoteca',
      'Festival Musical',
      'Exposición Arte',
      'Teatro',
      'Cine',
      'Museo',
      'Literatura',
      'Fotografía',
      'Pintura',
      'Escultura',
      'Danza',
      'Ópera',
      'Restaurante',
      'Tapas',
      'Cocina Internacional',
      'Vinos',
      'Cerveza Artesanal',
      'Repostería',
      'Brunch',
      'Food Truck',
      'Fiesta Privada',
      'Fiesta Temática',
      'Cumpleaños',
      'Boda',
      'Despedida',
      'After Work',
      'Networking',
      'Speed Dating',
      'Taller',
      'Curso',
      'Conferencia',
      'Seminario',
      'Workshop',
      'Idiomas',
      'Masterclass',
      'Hackathon',
      'Meetup Tech',
      'Gaming',
      'eSports',
      'Programación',
      'Inteligencia Artificial',
      'Blockchain',
      'Startups',
      'Meditación',
      'Spa',
      'Wellness',
      'Mindfulness',
      'Salud Mental',
      'Voluntariado Ambiental',
      'Voluntariado Social',
      'Donación de Sangre',
      'Rescate Animal',
      'Limpieza Playas',
      'Banco de Alimentos',
      'Camping',
      'Montañismo',
      'Playa',
      'Barbacoa',
      'Picnic',
      'Observación Aves',
      'Safari',
      'Juegos de Mesa',
      'Ajedrez',
      'Poker',
      'Escape Room',
      'Paintball',
      'Laser Tag',
      'Bolos',
      'Evento Familiar',
      'Parque Infantil',
      'Teatro Infantil',
      'Animación Infantil',
      'Taller Niños',
      'Mercadillo',
      'Feria',
      'Turismo',
      'Excursión',
      'Compras',
      'Otros',
    ];

    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translate('events.filters'),
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        filterDateFrom.value = null;
                        filterDateTo.value = null;
                        filterCategory.value = null;
                      },
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Categoría',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: allCategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = allCategories[index];
                    return Obx(() {
                      final isSelected = filterCategory.value == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          filterCategory.value = val ? cat : null;
                        },
                        selectedColor: context.theme.colorScheme.primary
                            .withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? context.theme.colorScheme.primary
                              : context.theme.hintColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Rango de fechas',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDateTile(
                        context,
                        'Desde',
                        filterDateFrom,
                        () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: filterDateFrom.value ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) filterDateFrom.value = date;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateTile(
                        context,
                        'Hasta',
                        filterDateTo,
                        () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                filterDateTo.value ??
                                (filterDateFrom.value ?? DateTime.now()),
                            firstDate: filterDateFrom.value ?? DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) filterDateTo.value = date;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      isSearching.value = true;
                      fetchEventos(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Aplicar Filtros',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDateTile(
    BuildContext context,
    String label,
    Rxn<DateTime> dateObs,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.theme.hintColor,
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                dateObs.value != null
                    ? '${dateObs.value!.day}/${dateObs.value!.month}/${dateObs.value!.year}'
                    : 'Seleccionar',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchCalendarEvents(DateTime from, DateTime to) async {
    try {
      isLoading.value = true;
      final events = await _eventosServices.getCalendarEvents(from, to);
      calendarEvents.assignAll(events);
    } catch (e) {
      logger.e('❌ Error fetching calendar events', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecommended({bool isRefresh = false}) async {
    logger.i(
      '🌟 [EventoController] fetchRecommended INICIAL - isRefresh: $isRefresh, hasMore: ${hasMoreRecommended.value}, isLoadingMore: ${isRecommendedLoadingMore.value}',
    );

    if (isRefresh) {
      currentRecommendedPage.value = 1;
      hasMoreRecommended.value = true;
    }

    if (!hasMoreRecommended.value || isRecommendedLoadingMore.value) return;

    try {
      if (currentRecommendedPage.value == 1) {
        isLoading.value = true;
      } else {
        isRecommendedLoadingMore.value = true;
      }

      final eventos = await _eventosServices.fetchRecommendedEvents(
        page: currentRecommendedPage.value,
        limit: 5, // Vamos de 5 en 5 para que se note la paginación horizontal
      );

      logger.i('🌟 [EventoController] Eventos recibidos: ${eventos.length}');

      if (eventos.isEmpty) {
        hasMoreRecommended.value = false;
      } else {
        if (currentRecommendedPage.value == 1) {
          recommendedEventos.assignAll(eventos);
        } else {
          recommendedEventos.addAll(eventos);
        }
        currentRecommendedPage.value++;

        // Si han llegado menos del límite, es que no hay más
        if (eventos.length < 5) {
          hasMoreRecommended.value = false;
        }
      }
    } catch (e) {
      logger.e('❌ Error en fetchRecommended', error: e);
    } finally {
      isLoading.value = false;
      isRecommendedLoadingMore.value = false;
    }
  }

  Future<void> fetchMoreRecommended() async {
    await fetchRecommended();
  }

  void showRecommendedOnly() {
    searchEditingController.text = 'Recomendado'; // Visual feedback only
    filterCategory.value = null;
    currentFilter.value = EventFilter.recommended; // Use the new filter state
    isSearching.value = true;

    // Assign immediately if we have them, otherwise fetch
    if (recommendedEventos.isNotEmpty) {
      eventosList.assignAll(recommendedEventos);
    } else {
      fetchEventos(1);
    }
  }
}
