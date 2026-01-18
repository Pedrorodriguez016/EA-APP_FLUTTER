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
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ea_seminari_9/Models/evento_photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart' as d;

enum EventFilter { all, myEvents }

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
  var isPrivate = false.obs;
  var friendsList = <User>[].obs;
  var selectedInvitedUsers = <String>[].obs;
  var isLoadingFriends = false.obs;
  final UserServices _userServices = UserServices();
  var userLocation = Rxn<LatLng>();
  var isLoadingLocation = false.obs;
  // Barcelona como ubicación por defecto
  final LatLng defaultLocation = const LatLng(41.3851, 2.1734);

  EventoController(this._eventosServices);
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
    _getUserLocation();
    scrollController.addListener(_scrollListener);
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
    capacidadMaximaController.dispose();
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

      // Si hay búsqueda por texto, categoría o fechas, usamos el endpoint /search
      if (searchText.isNotEmpty ||
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
        print('Servicio de ubicación deshabilitado');
        userLocation.value = defaultLocation;
        isLoadingLocation.value = false;
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permisos de ubicación denegados');
          userLocation.value = defaultLocation;
          isLoadingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permisos de ubicación denegados permanentemente');
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
      print(
        'Ubicación del usuario: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
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

  Future<void> refreshEventos() async {
    searchEditingController.clear();
    await fetchEventos(1);
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
          enListaEspera ? "En lista de espera" : "Éxito!",
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
      print("Error fetching friends: $e");
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

      // Mostrar opciones para elegir modo
      final result = await Get.bottomSheet<Map<String, dynamic>>(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.context!.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Compartir contenido',
                style: Get.context!.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.collections),
                title: const Text('Galería'),
                onTap: () => Get.back(result: {'mode': 'gallery'}),
              ),
            ],
          ),
        ),
      );

      if (result == null) return;

      final String mode = result['mode'];

      List<XFile> files = [];
      if (mode == 'gallery') {
        // pickMultipleMedia permite seleccionar varios elementos a la vez (fotos y videos)
        files = await picker.pickMultipleMedia();
      } else if (mode == 'camera_photo') {
        final XFile? file = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        if (file != null) files.add(file);
      } else if (mode == 'camera_video') {
        final XFile? file = await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 5),
        );
        if (file != null) files.add(file);
      }

      if (files.isEmpty) return;

      isLoading(true);
      int successCount = 0;

      for (var file in files) {
        try {
          final newPhoto = await _eventosServices.uploadMedia(
            eventId,
            file.path,
          );
          eventoPhotos.insert(0, newPhoto);
          successCount++;
        } catch (e) {
          logger.e('Error subiendo archivo ${file.name}: $e');
        }
      }

      if (successCount > 0) {
        Get.snackbar(
          '¡Éxito!',
          successCount == 1
              ? 'Contenido compartido correctamente'
              : '$successCount elementos compartidos correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (files.isNotEmpty) {
        Get.snackbar(
          'Error',
          'No se pudo compartir el contenido',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      logger.e('Error uploading media: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error al procesar el contenido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> deletePhoto(String eventId, String photoId) async {
    try {
      isLoading(true);
      await _eventosServices.deleteEventoPhoto(eventId, photoId);
      eventoPhotos.removeWhere((p) => p.id == photoId);
      Get.snackbar(
        '¡Éxito!',
        'Contenido eliminado correctamente',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      logger.e('Error deleting media: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar el contenido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> downloadMedia(String url) async {
    try {
      // Pedir permiso si es necesario
      bool hasPermission = await Gal.hasAccess();
      if (!hasPermission) {
        hasPermission = await Gal.requestAccess();
      }
      if (!hasPermission) {
        Get.snackbar('Permiso denegado', 'Se requiere acceso a la galería');
        return;
      }

      Get.snackbar(
        'Descargando...',
        'Iniciando descarga de contenido',
        showProgressIndicator: true,
      );

      final dio = d.Dio();
      final tempDir = await getTemporaryDirectory();
      final fileName = url.split('/').last;
      // Asegurarse de quitar extensiones raras o parámetros de query si los hubiera
      final cleanFileName = fileName.split('?').first;
      final tempPath = '${tempDir.path}/$cleanFileName';

      await dio.download(
        url,
        tempPath,
        options: d.Options(
          headers: {'Authorization': 'Bearer ${_authController.token ?? ''}'},
        ),
      );

      await Gal.putImage(
        tempPath,
      ); // Gal.putImage sirve para fotos y videos en versiones recientes o detecta por extensión
      // En Gal 2.x+, se usa putImage o putVideo.
      // Si queremos ser precisos:
      if (tempPath.endsWith('.mp4') || tempPath.endsWith('.mov')) {
        await Gal.putVideo(tempPath);
      } else {
        await Gal.putImage(tempPath);
      }

      Get.snackbar(
        '¡Éxito!',
        'Imagen/Video guardado en la galería',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      logger.e('Error downloading media: $e');
      Get.snackbar(
        'Error',
        'No se pudo descargar el contenido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      _updateEventInLists(updatedEvento);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
                            .withOpacity(0.2),
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
                    ? "${dateObs.value!.day}/${dateObs.value!.month}/${dateObs.value!.year}"
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
    searchEditingController.text = 'Recomendado';
    filterCategory.value = null;
    isSearching.value = true;
    isLoading.value = false; // Asegurar que no se quede el spinner
    eventosList.assignAll(recommendedEventos);
  }
}
