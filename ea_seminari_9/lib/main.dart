import 'package:ea_seminari_9/Bindings/auth_bindings.dart';
import 'package:ea_seminari_9/Bindings/chat_list_binding.dart';
import 'package:ea_seminari_9/Bindings/gamificacion_binding.dart';
import 'package:ea_seminari_9/Screen/chat_list_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Bindings/chat_binding.dart';
import 'Screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/date_symbol_data_local.dart';
import 'Services/storage_service.dart';
import 'Services/local_notification_service.dart';
import 'package:geolocator/geolocator.dart';
import 'Screen/login_screen.dart';
import 'Screen/register_screen.dart';
import 'Screen/home.dart';
import 'Screen/user_list.dart';
import 'Screen/eventos_detail.dart';
import 'Screen/user_detail.dart';
import 'Screen/eventos_list.dart';
import 'Screen/settings_screen.dart';
import 'Bindings/user_bindings.dart';
import 'Screen/perfil_screen.dart';
import 'Screen/crear_evento_screen.dart';
import 'Screen/eventchat_screen.dart';
import 'Bindings/event_chat_binding.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/logger.dart';
import 'Screen/chatbot_screen.dart';
import 'Screen/gamificacion_screen.dart';
import 'Bindings/chatbot_binding.dart';
import 'utils/app_theme.dart';
import 'Screen/calendar_screen.dart';
import 'Screen/blocked_users_screen.dart';
import 'Screen/questionnaire_screen.dart';
import 'Services/language_preferences.dart';

void main() async {
  logger.i('🚀 Iniciando aplicación...');
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones locales
  await LocalNotificationService.init();

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'es',
    supportedLocales: ['es', 'en', 'ca', 'fr'],
    basePath: 'assets/i18n/',
    preferences: LanguagePreferences(),
  );
  await initializeDateFormatting(null, null);
  timeago.setLocaleMessages('es', timeago.EsMessages());
  timeago.setLocaleMessages('ca', timeago.CaMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  await dotenv.load(fileName: '.env');
  logger.i('✅ Configuración completada, inicializando servicios');

  await Get.putAsync<StorageService>(() async => await StorageService().init());

  // Gestionar permisos de forma secuencial (sin bloquear el arranque)
  _requestPermissionsSequentially();

  logger.i('✅ Servicios inicializados, iniciando aplicación');
  runApp(LocalizedApp(delegate, const MyApp()));
}

Future<void> _requestPermissionsSequentially() async {
  logger.i('🛡️ Gestionando permisos secuencialmente...');
  try {
    // 1. Petición de localización (espera a que el usuario decida)
    await Geolocator.requestPermission();
    logger.i('📍 Permiso de localización procesado');

    // 2. Petición de notificaciones (solo cuando el anterior ha terminado)
    await LocalNotificationService.requestPermission();
    logger.i('🔔 Permiso de notificaciones procesado');
  } catch (e) {
    logger.e('❌ Error en la secuencia de permisos', error: e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    final storage = Get.find<StorageService>();
    final ThemeMode initialThemeMode = storage.getThemeMode();

    return GetMaterialApp(
      title: 'Eventer',
      initialBinding: AuthBinding(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        localizationDelegate,
      ],
      supportedLocales: localizationDelegate.supportedLocales,
      locale: localizationDelegate.currentLocale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => HomeScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/eventos',
          page: () => const EventosListScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/users',
          page: () => const UserListScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/settings',
          page: () => SettingsScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/user/:id',
          page: () => UserDetailScreen(userId: Get.parameters['id']!),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/evento/:id',
          page: () => EventosDetailScreen(eventoId: Get.parameters['id']!),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/profile',
          page: () => ProfileScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/crear_evento',
          page: () => const CrearEventoScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/chat-list',
          page: () => const ChatListScreen(),
          binding: ChatListBinding(),
        ),
        GetPage(
          name: '/chat',
          page: () => const ChatScreen(),
          binding: ChatBinding(),
        ),
        GetPage(
          name: '/chatbot',
          page: () => const ChatBotScreen(),
          binding: ChatBotBinding(),
        ),
        GetPage(
          name: '/event-chat',
          page: () => const EventChatScreen(),
          binding: EventChatBinding(),
        ),
        GetPage(
          name: '/calendar',
          page: () => CalendarScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/gamificacion',
          page: () => GamificacionScreen(),
          binding: GamificacionBinding(),
        ),
        GetPage(
          name: '/blocked-users',
          page: () => const BlockedUsersScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/questionnaire',
          page: () => const QuestionnaireScreen(),
          binding: UserBinding(),
        ),
      ],
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
    );
  }
}
