import 'package:ea_seminari_9/Bindings/chat_list_binding.dart';
import 'package:ea_seminari_9/Screen/chat_list_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/Bindings/chat_binding.dart';
import '/Screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/date_symbol_data_local.dart';
import 'Controllers/auth_controller.dart';
import 'Screen/login_screen.dart';
import 'Screen/register_screen.dart';
import 'Screen/home.dart';
import 'Screen/user_list.dart';
import 'Screen/eventos_detail.dart';
import 'Bindings/eventos_binding.dart';
import 'Screen/user_detail.dart';
import 'Screen/eventos_list.dart';
import 'Screen/settings_screen.dart';
import 'Bindings/user_bindings.dart';
import '../Screen/perfil_screen.dart';
import 'Screen/crear_evento_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
   var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'es', // Idioma por defecto si falla
    supportedLocales: ['es', 'en', 'ca', 'fr'], // Idiomas soportados
    basePath: 'assets/i18n/', // Ruta donde guardaste los JSON
  );
  await initializeDateFormatting('es', null);
  timeago.setLocaleMessages('es', timeago.EsMessages());
  await dotenv.load(fileName: ".env");
  runApp(LocalizedApp(delegate, const MyApp()));
   
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    Get.put(AuthController());

    return GetMaterialApp(
      title: 'Eventer',
      localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
        ),
        GetPage(
          name: '/home',
          page: () =>  HomeScreen(),
          binding: UserBinding(),
        ),
        GetPage(
          name: '/eventos',
          page: () => EventosListScreen(),
          binding: EventosBinding(), 
        ),
        GetPage(
          name: '/users',
          page: () => const UserListScreen(),
          binding: UserBinding(), 
        ),
        GetPage(
          name: '/settings',
          page: () => SettingsScreen(),
        ),
        GetPage(
          name: '/user/:id',
          page: () => UserDetailScreen(userId: Get.parameters['id']!),
          binding: UserBinding(),
        ),
         GetPage(
          name: '/evento/:id',
          page: () => EventosDetailScreen(eventoId: Get.parameters['id']!),
          binding: EventosBinding(),
         ),
         GetPage(
          name: '/profile',
          page: () => ProfileScreen(),
          binding: UserBinding(),
        ),
          GetPage(
            name: '/crear_evento',
            page: () => const CrearEventoScreen(),
            binding: EventosBinding(),
          ),
          GetPage(
            name: '/chat-list',
             page: () => const ChatListScreen(),
             binding: ChatListBinding()
             ),
          GetPage(
            name: '/chat', 
            page: () => const ChatScreen(),
            binding: ChatBinding()
            ), 
      ],
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
    );
  }
}