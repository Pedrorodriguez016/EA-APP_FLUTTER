import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter/material.dart';
import '../Models/user.dart';
import '../Services/auth_service.dart';
import '../Services/storage_service.dart';
import '../utils/logger.dart';
import '../Services/user_services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  // Dependencias
  final AuthService _authService = Get.find<AuthService>();
  StorageService get _storageService => Get.find<StorageService>();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController loginUserCtrl = TextEditingController();
  final TextEditingController loginPassCtrl = TextEditingController();

  var isLoginLoading = false.obs;
  var isObscurePassword = true.obs;
  // Estado
  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();
  String? token;
  String? refreshToken;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  @override
  void onInit() {
    super.onInit();
    _initGoogleSignIn();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLogin();
    });
  }

  Future<void> _initGoogleSignIn() async {
    try {
      // Inicializar el plugin con el serverClientId proporcionado
      await _googleSignIn.initialize(serverClientId: dotenv.env['GOOGLE_ID']!);

      // Escuchar eventos de autenticación
      _googleSignIn.authenticationEvents
          .listen((event) {
            if (event is GoogleSignInAuthenticationEventSignIn) {
              _handleGoogleSignInSuccess(event.user);
            }
          })
          .onError((e) {
            logger.e('Error en stream de Google Sign-In', error: e);
          });
    } catch (e) {
      logger.e('Error al inicializar Google Sign-In', error: e);
    }
  }

  Future<void> _checkAutoLogin() async {
    User? savedUser = _storageService.getUser();
    if (savedUser != null) {
      if (savedUser.id.isEmpty) {
        logger.w('⚠️ Sesión corrupta (ID vacío). Cerrando sesión.');
        logout();
        return;
      }
      currentUser.value = savedUser;
      token = savedUser.token;
      refreshToken = savedUser.refreshToken;
      isLoggedIn.value = true;
      Get.offAllNamed('/home');
    }
  }

  Future<void> submitLogin() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoginLoading.value = true; // Activar spinner

      final username = loginUserCtrl.text.trim();
      final password = loginPassCtrl.text.trim();

      final data = await _authService.login(username, password);

      final userData = data['user'];
      final user = User.fromJson({
        ...userData,
        'token': data['token'],
        'refreshToken': data['refreshToken'],
      });

      currentUser.value = user;
      token = data['token'];
      refreshToken = data['refreshToken'];
      isLoggedIn.value = true;

      await _storageService.saveSession(user);
      loginUserCtrl.clear();
      loginPassCtrl.clear();

      Get.offAllNamed('/home');

      Get.snackbar(
        translate('common.success'),
        translate('auth.login.success_msg'),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String msg = errorData != null && errorData['error'] != null
          ? errorData['error']
          : translate('common.error');
      Get.snackbar(
        translate('common.error'),
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        translate('common.error'),
        '$e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoginLoading.value = true;
      if (_googleSignIn.supportsAuthenticate()) {
        await _googleSignIn.authenticate();
      } else {
        throw Exception(translate('auth.errors.google_unsupported'));
      }
    } catch (e) {
      logger.e('Error al iniciar flujo de Google', error: e);
      isLoginLoading.value = false;
      Get.snackbar(
        translate('common.error'),
        '${translate('auth.errors.google_failed')}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    // El spinner se desactiva en _handleGoogleSignInSuccess o por error
  }

  Future<void> _handleGoogleSignInSuccess(GoogleSignInAccount user) async {
    try {
      // En v7.0+, authentication no es un Future
      final GoogleSignInAuthentication googleAuth = user.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception(translate('auth.errors.google_token_error'));
      }

      final data = await _authService.loginWithGoogle(idToken);

      final userData = data['user'];
      final userModel = User.fromJson({
        ...userData,
        'token': data['token'],
        'refreshToken': data['refreshToken'],
      });

      currentUser.value = userModel;
      token = data['token'];
      refreshToken = data['refreshToken'];
      isLoggedIn.value = true;

      await _storageService.saveSession(userModel);
      Get.offAllNamed('/home');

      Get.snackbar(
        translate('common.success'),
        translate('auth.login.success_msg'),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      logger.e('Error al procesar login de Google con el backend', error: e);
      Get.snackbar(
        translate('common.error'),
        '${translate('common.error')}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  void logout() {
    isLoggedIn.value = false;
    currentUser.value = null;
    token = null;
    refreshToken = null;
    _storageService.clearSession();

    loginUserCtrl.clear();
    loginPassCtrl.clear();
    isObscurePassword.value = true;

    // Solo navegar si no estamos ya en la pantalla de login
    if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login');
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = currentUser.value;
      if (user != null) {
        final updatedUser = await Get.find<UserServices>().fetchUserById(
          user.id,
        );
        currentUser.value = updatedUser;
        await _storageService.saveSession(updatedUser);
        logger.i('✅ Usuario actualizado desde el backend');
      }
    } catch (e) {
      logger.e('❌ Error al refrescar usuario actual', error: e);
    }
  }

  Future<Map<String, dynamic>> register(User newUser) async {
    try {
      await _authService.register(newUser);
      logger.i('✅ Registro completado. Iniciando sesión automática...');

      // Realizamos el login automático usando las credenciales del registro
      final loginData = await _authService.login(
        newUser.username,
        newUser.password!,
      );

      final userData = loginData['user'];
      final user = User.fromJson({
        ...userData,
        'token': loginData['token'],
        'refreshToken': loginData['refreshToken'],
      });

      currentUser.value = user;
      token = loginData['token'];
      refreshToken = loginData['refreshToken'];
      isLoggedIn.value = true;

      await _storageService.saveSession(user);
      logger.i('✅ Login automático tras registro exitoso');

      return {
        'success': true,
        'message': translate('auth.register.success_msg'),
      };
    } on DioException catch (e) {
      final errorData = e.response?.data;
      return {
        'success': false,
        'message': errorData != null && errorData['error'] != null
            ? errorData['error']
            : translate('common.error'),
      };
    } catch (e) {
      return {'success': false, 'message': '${translate("common.error")}: $e'};
    }
  }

  void togglePasswordVisibility() {
    isObscurePassword.value = !isObscurePassword.value;
  }

  @override
  void onClose() {
    loginUserCtrl.dispose();
    loginPassCtrl.dispose();
    super.onClose();
  }
}
