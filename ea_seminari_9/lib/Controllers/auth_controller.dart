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
  }

  Future<void> _handleGoogleSignInSuccess(GoogleSignInAccount user) async {
    try {
      final GoogleSignInAuthentication googleAuth = user.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception(translate('auth.errors.google_token_error'));
      }

      // 1. Sincronizado con la web: Comprobar si el usuario existe y qué necesita
      final checkData = await _authService.checkGoogleUser(idToken);

      String? finalUsername;
      String? finalBirthday;

      if (checkData['exists'] == true && checkData['needsData'] == false) {
        logger.i('✅ Usuario Google ya existe, procediendo a login directo');
      } else {
        final result = await _showGoogleDataDialog(
          suggestedUsername:
              checkData['suggestedUsername'] ?? user.displayName ?? '',
          needsUsername:
              checkData['exists'] == false || checkData['hasUsername'] == false,
          needsBirthday:
              checkData['exists'] == false || checkData['hasBirthday'] == false,
        );

        if (result == null) {
          isLoginLoading.value = false;
          return;
        }

        finalUsername = result['username'];
        finalBirthday = result['birthday'];
      }

      final data = await _authService.loginWithGoogle(
        idToken,
        birthday: finalBirthday,
        username: finalUsername,
      );

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

      // Si es un usuario nuevo o necesitaba completar datos, lo mandamos al cuestionario
      if (checkData['exists'] == false || checkData['needsData'] == true) {
        logger.i(
          '🆕 Nuevo usuario de Google o requiere datos. Redirigiendo a cuestionario.',
        );
        Get.offAllNamed('/questionnaire');
      } else {
        Get.offAllNamed('/home');
      }

      Get.snackbar(
        translate('common.success'),
        translate('auth.login.success_msg'),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      logger.e('Error al procesar login de Google con el backend', error: e);
      String errorMsg = e.toString();
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? e.message;
        if (e.response?.data['message'] == 'USERNAME_EXISTS') {
          errorMsg = 'El nombre de usuario ya está en uso. Prueba con otro.';
        }
      }

      Get.snackbar(
        translate('common.error'),
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<Map<String, String>?> _showGoogleDataDialog({
    required String suggestedUsername,
    bool needsUsername = true,
    bool needsBirthday = true,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = now.subtract(const Duration(days: 18 * 365));

    final TextEditingController userCtrl = TextEditingController(
      text: suggestedUsername,
    );
    final TextEditingController birthCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await Get.dialog<Map<String, String>>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          translate('auth.google_data_title'),
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: Get.height * 0.6),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translate('auth.google_data_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  if (needsUsername)
                    TextFormField(
                      controller: userCtrl,
                      decoration: InputDecoration(
                        labelText: translate('auth.fields.username'),
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? translate('auth.errors.username_empty')
                          : null,
                    ),
                  if (needsBirthday) ...[
                    if (needsUsername) const SizedBox(height: 16),
                    TextFormField(
                      controller: birthCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: translate('auth.fields.birthday'),
                        hintText: translate('auth.fields.birthday_hint'),
                        prefixIcon: const Icon(Icons.cake),
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: initialDate,
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (picked != null) {
                          birthCtrl.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return translate('auth.errors.birthday_empty');
                        }
                        final birth = DateTime.tryParse(v);
                        if (birth != null) {
                          final age = now.year - birth.year;
                          if (age < 13) {
                            return translate('auth.errors.age_restriction');
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(translate('common.cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back(
                  result: {
                    'username': userCtrl.text,
                    'birthday': birthCtrl.text,
                  },
                );
              }
            },
            child: Text(translate('common.continue')),
          ),
        ],
      ),
      barrierDismissible: false,
    );
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
