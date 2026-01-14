import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
        'eventer_channel_id',
        'Eventer Notifications',
        channelDescription: 'Canal para notificaciones de eventos y mensajes',
        importance: Importance.max,
        priority: Priority.max,
        ticker: 'ticker',
        fullScreenIntent: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        showWhen: true,
      );

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          final payload = details.payload!;
          logger.i('🔔 Notificación pulsada con payload: $payload');

          if (payload.startsWith('chat|')) {
            final parts = payload.split('|');
            if (parts.length >= 3) {
              Get.toNamed(
                '/chat',
                arguments: {'friendId': parts[1], 'friendName': parts[2]},
              );
            }
          } else {
            // Mapeo dinámico: si el backend envía algo tipo web (/menu),
            // lo traducimos a lo que Flutter entiende (/home)
            String targetRoute = payload;
            if (targetRoute == '/menu') {
              targetRoute = '/home';
            }
            Get.toNamed(targetRoute);
          }
        }
      },
    );

    logger.i('✅ Local Notifications Initialized');
  }

  static Future<void> requestPermission() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    logger.i('🔔 Mostrando notificación local: $title - $body');
    const NotificationDetails details = NotificationDetails(
      android: _androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }
}
