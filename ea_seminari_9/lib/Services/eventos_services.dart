import 'package:ea_seminari_9/Models/user.dart';
import '../Models/eventos.dart';
import 'package:dio/dio.dart';
import '../Interceptor/auth_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';
import 'package:get/get.dart';
import '../Services/storage_service.dart';

class EventosServices {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/event';
  late final Dio _client;
  final User currentUser = Get.find<StorageService>().getUser()!;

  EventosServices() {
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
    String? creatorId,
  }) async {
    try {
      logger.d('📄 Obteniendo eventos - Página: $page, Límite: $limit');

      final response = await _client.get(
        '/visible',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (q.isNotEmpty) 'q': q,
        },
      );

      final responseData = response.data;

      // Intentar obtener la lista de eventos buscando en 'data' o 'docs'
      final List<dynamic> eventosList =
          responseData['data'] ?? responseData['docs'] ?? [];

      logger.i('✅ Respuesta recibida. Claves: ${responseData.keys.join(", ")}');
      logger.i('✅ Eventos obtenidos: ${eventosList.length}');

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

  Future<Evento> joinEvent(String eventId) async {
    try {
      logger.i('💪 Uniendose al evento: $eventId');
      final response = await _client.post('/$eventId/join');
      final data = response.data;

      // El backend devuelve { message, evento, enListaEspera }
      if (data is Map && data.containsKey('evento')) {
        return Evento.fromJson(data['evento']);
      }
      return Evento.fromJson(data);
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

      // El backend devuelve { message, evento }
      if (data is Map && data.containsKey('evento')) {
        return Evento.fromJson(data['evento']);
      }
      return Evento.fromJson(data);
    } catch (e) {
      logger.e('❌ Error al salir del evento', error: e);
      throw Exception('Error al salir del evento: $e');
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
      print('Error in acceptInvitation: $e');
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
      print('Error in rejectInvitation: $e');
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
}
