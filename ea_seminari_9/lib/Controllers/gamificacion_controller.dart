import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../Models/usuario_progreso.dart';
import '../Models/insignia.dart';
import '../Services/gamificacion_services.dart';

class GamificacionController extends GetxController {
  final _gamificacionServices = GamificacionServices();

  final logger = Logger();

  // Estado
  var isLoading = false.obs;
  Rxn<UsuarioProgreso> miProgreso = Rxn<UsuarioProgreso>();
  var ranking = <RankingUsuario>[].obs;
  var insigniasDisponibles = <Insignia>[].obs;

  @override
  void onInit() {
    super.onInit();

    cargarMiProgreso();
    cargarInsignias();
  }

  // Cargar mi progreso
  Future<void> cargarMiProgreso() async {
    try {
      isLoading(true);
      final progreso = await _gamificacionServices.getMiProgreso();
      miProgreso.value = progreso;
      logger.d('Progreso cargado: ${progreso.puntos} puntos');
    } catch (e) {
      logger.w('Backend de gamificación no disponible: $e');
      // No mostrar error al usuario, el backend puede no estar activo
    } finally {
      isLoading(false);
    }
  }

  // Cargar progreso de otro usuario
  Future<UsuarioProgreso?> cargarProgresoUsuario(String usuarioId) async {
    try {
      isLoading(true);
      final progreso = await _gamificacionServices.getProgresoUsuario(
        usuarioId,
      );
      logger.d('Progreso de usuario $usuarioId cargado');
      return progreso;
    } catch (e) {
      logger.e('Error al cargar progreso de usuario: $e');
      Get.snackbar(
        'Error',
        'No se pudo cargar el progreso del usuario',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading(false);
    }
  }

  // Cargar ranking
  Future<void> cargarRanking({int limite = 10}) async {
    try {
      isLoading(true);
      final listaRanking = await _gamificacionServices.getRanking(
        limite: limite,
      );
      ranking.assignAll(listaRanking);
      logger.d('Ranking cargado: ${listaRanking.length} usuarios');
    } catch (e) {
      logger.w('Backend de gamificación no disponible para ranking: $e');
    } finally {
      isLoading(false);
    }
  }

  // Cargar insignias disponibles
  Future<void> cargarInsignias() async {
    try {
      final insignias = await _gamificacionServices.getInsignias();
      insigniasDisponibles.assignAll(insignias);
      logger.d('Insignias cargadas: ${insignias.length}');
    } catch (e) {
      logger.w('Backend de gamificación no disponible para insignias: $e');
    }
  }

  // Helper para obtener el nivel siguiente
  String getNivelSiguiente() {
    final nivelActual = miProgreso.value?.nivel ?? 'Novato';
    const niveles = [
      'Novato',
      'Explorador',
      'Organizador',
      'Experto',
      'Leyenda',
    ];
    final indexActual = niveles.indexOf(nivelActual);
    if (indexActual < niveles.length - 1) {
      return niveles[indexActual + 1];
    }
    return 'Máximo nivel alcanzado';
  }

  // Helper para calcular progreso al siguiente nivel
  double getProgresoNivel() {
    final puntos = miProgreso.value?.puntos ?? 0;
    const puntosNiveles = [0, 100, 300, 600, 1000, 2000];
    final nivel = miProgreso.value?.nivel ?? 'Novato';
    const niveles = [
      'Novato',
      'Explorador',
      'Organizador',
      'Experto',
      'Leyenda',
    ];

    final indexActual = niveles.indexOf(nivel);
    if (indexActual >= niveles.length - 1) {
      return 1.0; // Nivel máximo
    }

    final puntosActuales = puntosNiveles[indexActual];
    final puntosSiguientes = puntosNiveles[indexActual + 1];
    final progreso =
        (puntos - puntosActuales) / (puntosSiguientes - puntosActuales);

    return progreso.clamp(0.0, 1.0);
  }
}
