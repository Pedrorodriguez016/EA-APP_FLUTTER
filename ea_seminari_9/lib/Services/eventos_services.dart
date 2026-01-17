import 'package:ea_seminari_9/Models/user.dart';
import '../Models/eventos.dart';
import '../Models/evento_photo.dart';
import 'package:dio/dio.dart';
import '../Interceptor/auth_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../Services/storage_service.dart';

class EventosServices {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/event';
  late final Dio _client;
  final User currentUser = Get.find<StorageService>().getUser()!;

  EventosServices() {
    logger.i('🚀 [EventosServices] Constructor iniciado');
    _client = Dio(BaseOptions(baseUrl: baseUrl));
    _client.interceptors.add(AuthInterceptor());
  }

  Future<List<Evento>> fetchEventsByBounds({
    required double north,
    required double south,
    required double east,
    required double west,
  }) async {
    try {
      logger.d('🗺️ Obteniendo eventos por límites geográficos');
      final response = await _client.get(
        '/by-bounds',
        queryParameters: {
          'north': north,
          'south': south,
          'east': east,
          'west': west,
          'limit': 10,
        },
      );

      var data = response.data;
      List<dynamic> eventosList;

      if (data is List) {
        eventosList = data;
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        eventosList = data['data'];
      } else {
        eventosList = [];
      }
      logger.i('✅ Eventos obtenidos por bounds: ${eventosList.length}');
      return eventosList.map((json) => Evento.fromJson(json)).toList();
    } catch (e) {
      logger.e('❌ Error en fetchEventsByBounds', error: e);
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchEvents({
    int page = 1,
    int limit = 20,
    String q = '',
    String? category,
  }) async {
    try {
      logger.d(
        '📄 Obteniendo eventos - Página: $page, Límite: $limit, Categoria: $category',
      );

      final response = await _client.get(
        '/visible',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (q.isNotEmpty) 'q': q,
          if (category != null && category.isNotEmpty) 'categoria': category,
        },
      );

      final responseData = response.data;
      final List<dynamic> eventosList =
          responseData['data'] ?? responseData['docs'] ?? [];

      return {
        'eventos': eventosList.map((json) => Evento.fromJson(json)).toList(),
        'totalPages': responseData['totalPages'] ?? responseData['pages'] ?? 1,
        'currentPage': responseData['page'] ?? responseData['currentPage'] ?? 1,
        'total': responseData['totalItems'] ?? responseData['totalDocs'] ?? 0,
      };
    } catch (e) {
      logger.e('❌ Error al cargar eventos', error: e);
      throw Exception('Error al cargar eventos: $e');
    }
  }

  Future<Map<String, dynamic>> searchEvents({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      logger.d('🔍 Buscando eventos con filtros avanzados');
      final response = await _client.get(
        '/search',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (category != null) 'categoria': category,
          if (dateFrom != null) 'dateFrom': dateFrom,
          if (dateTo != null) 'dateTo': dateTo,
        },
      );

      final responseData = response.data;
      final List<dynamic> eventosList = responseData['data'] ?? [];

      return {
        'eventos': eventosList.map((json) => Evento.fromJson(json)).toList(),
        'totalPages': responseData['totalPages'] ?? 1,
        'currentPage': responseData['page'] ?? 1,
        'total': responseData['totalItems'] ?? 0,
      };
    } catch (e) {
      logger.e('❌ Error en búsqueda avanzada', error: e);
      throw Exception('Error en búsqueda de eventos: $e');
    }
  }

  Future<Evento> fetchEventById(String id) async {
    try {
      logger.d('📄 Obteniendo evento con ID: $id');
      final response = await _client.get('/$id');
      logger.i('✅ Evento obtenido: ${response.data['title'] ?? id}');

      return Evento.fromJson(response.data);
    } catch (e) {
      logger.e('❌ Error al cargar evento', error: e);
      throw Exception('Error al cargar el usuario: $e');
    }
  }

  Future<Evento> createEvento(Map<String, dynamic> data) async {
    try {
      logger.i('📁 Creando nuevo evento: ${data['title'] ?? "sin título"}');
      final response = await _client.post(
        '/',
        data: data, // Envía los datos del nuevo evento
      );
      logger.i('✅ Evento creado exitosamente');
      return Evento.fromJson(response.data);
    } catch (e) {
      logger.e('❌ Error al crear evento', error: e);
      throw Exception('Error al crear el evento: $e');
    }
  }

  Future<Evento?> getEventoByName(String name) async {
    try {
      logger.d('📄 Búsqueda de evento por nombre: $name');
      final response = await _client.get('/by-name/$name');
      logger.i('✅ Evento encontrado: $name');
      return Evento.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        logger.w('⚠️ Evento no encontrado: $name');
        return null;
      }
      logger.e('❌ Error al buscar evento', error: e);

      throw Exception('Error al buscar usuario por username: ${e.message}');
    } catch (e) {
      logger.e('❌ Error desconocido al buscar evento', error: e);
      throw Exception('Error desconocido al buscar usuario: $e');
    }
  }

  Future<Map<String, dynamic>> joinEvent(String eventId) async {
    try {
      logger.i('💪 Uniéndose al evento: $eventId');
      final response = await _client.post('/$eventId/join');
      final data = response.data;

      return {
        'evento': Evento.fromJson(data['evento']),
        'enListaEspera': data['enListaEspera'] ?? false,
        'mensaje': data['mensaje'] ?? 'Te has unido al evento',
      };
    } catch (e) {
      logger.e('❌ Error al unirse al evento', error: e);
      throw Exception('Error al unirse al evento: $e');
    }
  }

  Future<Evento> leaveEvent(String eventId) async {
    try {
      logger.i('🚪 Saliendo del evento: $eventId');
      final response = await _client.post('/$eventId/leave');
      final data = response.data;

      // El backend devuelve { message, evento } o directamente el evento
      if (data is Map && data.containsKey('evento')) {
        logger.i('✅ Salida exitosa del evento');
        return Evento.fromJson(data['evento']);
      }
      return Evento.fromJson(data);
    } catch (e) {
      logger.e('❌ Error al salir del evento', error: e);
      throw Exception('Error al salir del evento: $e');
    }
  }

  Future<Evento> leaveWaitlist(String eventId) async {
    try {
      final response = await _client.delete('/$eventId/waitlist');

      return Evento.fromJson(response.data['evento']);
    } catch (e) {
      logger.e('Error in leaveWaitlist: $e');
      throw Exception('Error al salir de la lista de espera: $e');
    }
  }

  Future<Map<String, dynamic>> getWaitlistPosition(String eventId) async {
    try {
      final response = await _client.get('/$eventId/waitlist/position');

      return {
        'position': response.data['position'] ?? -1,
        'enListaEspera': response.data['enListaEspera'] ?? false,
      };
    } catch (e) {
      logger.e('Error in getWaitlistPosition: $e');
      throw Exception('Error al obtener posición en lista: $e');
    }
  }

  Future<Evento> acceptInvitation(String eventId) async {
    try {
      final response = await _client.post('/$eventId/accept-invitation');
      final data = response.data;
      if (data is Map && data.containsKey('evento')) {
        return Evento.fromJson(data['evento']);
      }
      return Evento.fromJson(data);
    } catch (e) {
      logger.e('Error in acceptInvitation: $e');
      throw Exception('Error al aceptar invitación: $e');
    }
  }

  Future<Evento> rejectInvitation(String eventId) async {
    try {
      final response = await _client.post('/$eventId/reject-invitation');
      final data = response.data;
      if (data is Map && data.containsKey('evento')) {
        return Evento.fromJson(data['evento']);
      }
      return Evento.fromJson(data);
    } catch (e) {
      logger.e('Error in rejectInvitation: $e');
      throw Exception('Error al rechazar invitación: $e');
    }
  }

  Future<Map<String, List<Evento>>> getMisEventos() async {
    try {
      final response = await _client.get('/user/my-events');
      final data = response.data;

      final creados =
          (data['eventosCreados'] as List?)
              ?.map((e) => Evento.fromJson(e))
              .toList() ??
          [];

      final inscritos =
          (data['eventosInscritos'] as List?)
              ?.map((e) => Evento.fromJson(e))
              .toList() ??
          [];

      return {'creados': creados, 'inscritos': inscritos};
    } catch (e) {
      logger.e('❌ Error al obtener mis eventos', error: e);
      throw Exception('Error al cargar mis eventos: $e');
    }
  }

  Future<List<Evento>> getCalendarEvents(DateTime from, DateTime to) async {
    try {
      logger.d(
        '📅 Obteniendo eventos de calendario: ${from.toIso8601String()} - ${to.toIso8601String()}',
      );
      final response = await _client.get(
        '/calendar',
        queryParameters: {
          'dateFrom': from.toIso8601String(),
          'dateTo': to.toIso8601String(),
        },
      );

      final List<dynamic> data = response.data;
      logger.i('✅ Eventos de calendario obtenidos: ${data.length}');
      return data.map((json) => Evento.fromJson(json)).toList();
    } catch (e) {
      logger.e('❌ Error en getCalendarEvents', error: e);
      return [];
    }
  }

  Future<List<Evento>> fetchRecommendedEvents({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      logger.d('🌟 Obteniendo eventos recomendados (Pág: $page)');
      final response = await _client.get(
        '/recommended',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> eventosList = response.data['data'] ?? [];
      logger.i(
        '✅ Recomendaciones obtenidas: ${eventosList.length} (Pág: $page)',
      );

      return eventosList.map((json) => Evento.fromJson(json)).toList();
    } catch (e) {
      logger.e('❌ Error en fetchRecommendedEvents', error: e);
      return [];
    }
  }

  Future<EventoPhoto> uploadMedia(String eventId, String filePath) async {
    try {
      logger.i('📤 Subiendo contenido multimedia al evento: $eventId');
      String fileName = filePath.split('/').last;

      FormData formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _client.post('/$eventId/photos', data: formData);

      logger.i('✅ Contenido subido exitosamente');
      return EventoPhoto.fromJson(response.data);
    } catch (e) {
      logger.e('❌ Error al subir contenido al evento', error: e);
      throw Exception('Error al subir el contenido: $e');
    }
  }

  Future<List<EventoPhoto>> fetchEventPhotos(String eventId) async {
    try {
      logger.d('🖼️ Obteniendo fotos del evento: $eventId');
      final response = await _client.get('/$eventId/photos');

      final List<dynamic> data = response.data;
      logger.i('✅ Fotos obtenidas: ${data.length}');
      return data.map((json) => EventoPhoto.fromJson(json)).toList();
    } catch (e) {
      logger.e('❌ Error al obtener fotos del evento', error: e);
      return [];
    }
  }

  Future<List<Evento>> fetchPendingInvitations() async {
    try {
      logger.d('📩 Obteniendo invitaciones pendientes');
      final response = await _client.get('/invitations/pending');
      final List<dynamic> data = response.data['invitaciones'] ?? [];
      logger.i('✅ Invitaciones pendientes obtenidas: ${data.length}');
      return data.map((json) => Evento.fromJson(json)).toList();
    } catch (e) {
      logger.e('❌ Error en fetchPendingInvitations', error: e);
      return [];
    }
  }

  Future<Evento> updateEvento(String id, Map<String, dynamic> data) async {
    try {
      logger.i('🔄 Actualizando evento: $id');
      final response = await _client.put('/$id', data: data);
      logger.i('✅ Evento actualizado exitosamente');
      return Evento.fromJson(response.data);
    } catch (e) {
      logger.e('❌ Error al actualizar evento', error: e);
      throw Exception('Error al actualizar el evento: $e');
    }
  }

  Future<void> deleteEvento(String id) async {
    try {
      logger.i('🗑️ Eliminando evento: $id');
      await _client.delete('/$id');
      logger.i('✅ Evento eliminado exitosamente');
    } catch (e) {
      logger.e('❌ Error al eliminar evento', error: e);
      throw Exception('Error al eliminar el evento: $e');
    }
  }
}
