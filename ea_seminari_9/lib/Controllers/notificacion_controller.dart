import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/notificacion.dart';
import '../Services/notificacion_services.dart';
import '../Services/socket_services.dart';
import '../Controllers/auth_controller.dart';
import '../utils/logger.dart';
import '../Services/local_notification_service.dart';

class NotificacionController extends GetxController
    with WidgetsBindingObserver {
  final NotificacionServices _services = NotificacionServices();
  final SocketService _socketService = Get.find<SocketService>();
  final AuthController _authController = Get.find<AuthController>();

  var notificaciones = <Notificacion>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (_authController.currentUser.value != null) {
      fetchNotificaciones();
      listenToNotifications();
    }

    // Escuchar cambios en el usuario para reiniciar si es necesario
    ever(_authController.currentUser, (user) {
      if (user != null) {
        fetchNotificaciones();
        listenToNotifications();
      } else {
        _onLogout();
      }
    });
  }

  Future<void> fetchNotificaciones() async {
    final userId = _authController.currentUser.value?.id;
    if (userId == null) return;

    isLoading.value = true;
    try {
      logger.d(
        '📡 Pidiendo notificaciones al servidor para el usuario: $userId',
      );
      final list = await _services.fetchNotificaciones(userId);
      logger.i('✅ ${list.length} notificaciones recibidas del servidor');
      notificaciones.assignAll(list);
      _updateUnreadCount();
      logger.d('🔢 Contador de no leídas actualizado: ${unreadCount.value}');
    } catch (e) {
      logger.e(
        '❌ Error al refrescar notificaciones en el controlador',
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void listenToNotifications() {
    _socketService
        .stopListeningToNotifications(); // Limpiar listener previo si existe
    _socketService.listenToNotifications((data) {
      logger.i('🔔 Nueva notificación recibida vía Socket: $data');
      final newNotif = Notificacion.fromJson(data);

      try {
        // 1. Mostrar Snackbar (Aviso interno de la app) - PRIORIDAD
        Get.snackbar(
          newNotif.title,
          newNotif.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
          colorText: Colors.white,
          onTap: (_) => markAsRead(newNotif.id),
        );

        // 2. Actualizar lista y contador localmente
        notificaciones.insert(0, newNotif);
        _updateUnreadCount();

        // 3. Mostrar notificación de Android (Aviso externo)
        LocalNotificationService.show(
          id: newNotif.id.hashCode.abs(),
          title: newNotif.title,
          body: newNotif.message,
          payload: newNotif.actionUrl,
        );
      } catch (e) {
        logger.e('❌ Error procesando nueva notificación', error: e);
      }
    });
  }

  void _onLogout() {
    notificaciones.clear();
    unreadCount.value = 0;
    _socketService.stopListeningToNotifications();
  }

  void _updateUnreadCount() {
    unreadCount.value = notificaciones.where((n) => !n.read).length;
  }

  Future<void> markAsRead(String notificacionId) async {
    final index = notificaciones.indexWhere((n) => n.id == notificacionId);
    if (index != -1 && !notificaciones[index].read) {
      final success = await _services.markAsRead(notificacionId);
      if (success) {
        final current = notificaciones[index];
        notificaciones[index] = Notificacion(
          id: current.id,
          userId: current.userId,
          type: current.type,
          title: current.title,
          message: current.message,
          relatedUserId: current.relatedUserId,
          relatedEventId: current.relatedEventId,
          relatedUsername: current.relatedUsername,
          relatedEventName: current.relatedEventName,
          read: true,
          createdAt: current.createdAt,
          actionUrl: current.actionUrl,
        );
        _updateUnreadCount();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _authController.currentUser.value?.id;
    if (userId == null) return;

    await _services.markAllAsRead(userId);
    for (var i = 0; i < notificaciones.length; i++) {
      if (!notificaciones[i].read) {
        final current = notificaciones[i];
        notificaciones[i] = Notificacion(
          id: current.id,
          userId: current.userId,
          type: current.type,
          title: current.title,
          message: current.message,
          relatedUserId: current.relatedUserId,
          relatedEventId: current.relatedEventId,
          relatedUsername: current.relatedUsername,
          relatedEventName: current.relatedEventName,
          read: true,
          createdAt: current.createdAt,
          actionUrl: current.actionUrl,
        );
      }
    }
    _updateUnreadCount();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _onLogout();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final userId = _authController.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    if (state == AppLifecycleState.paused) {
      // App minimizada: Forzar Offline en DB pero mantener socket vivo
      logger.i(
        '📱 App en segundo plano, forzando estado Offline (Modo Invisible)',
      );
      _socketService.forceOffline(userId);
    } else if (state == AppLifecycleState.resumed) {
      // App abierta de nuevo: Volver a estar Online
      logger.i('📱 App vuelve a primer plano, restaurando estado Online');
      _socketService.connectWithUserId(userId);
      fetchNotificaciones();
    }
  }

  Future<void> deleteNotificacion(String notificacionId) async {
    final success = await _services.deleteNotificacion(notificacionId);
    if (success) {
      notificaciones.removeWhere((n) => n.id == notificacionId);
      _updateUnreadCount();
    }
  }
}
