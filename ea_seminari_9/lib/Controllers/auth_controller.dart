import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter/material.dart';
import '../Models/user.dart';
import '../Services/auth_service.dart'; 
import '../Services/storage_service.dart';

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


@override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _checkAutoLogin();
    });
  }


  Future <void> _checkAutoLogin() async {
    User? savedUser = _storageService.getUser();
    if (savedUser != null) {
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
        snackPosition: SnackPosition.BOTTOM
      );

    } on DioException catch (e) {
      final errorData = e.response?.data;
      String msg = errorData != null && errorData['error'] != null 
          ? errorData['error'] 
          : translate('common.error');
      Get.snackbar(translate('common.error'), msg, 
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(translate('common.error'), '$e', 
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
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
    // Sesión eliminada del Storage
    // Opcional: limpiar campos de texto
    loginUserCtrl.clear();
    loginPassCtrl.clear();
    isObscurePassword.value = true;

    Get.offAllNamed('/login');
  }

  Future<Map<String, dynamic>> register(User newUser) async {
    try {
      await _authService.register(newUser);
      return {'success': true, 'message': translate('auth.register.success_msg')};

    } on DioException catch (e) {
      final errorData = e.response?.data;
      return {
        'success': false, 
        'message': errorData != null && errorData['error'] != null 
            ? errorData['error'] 
            : translate('common.error')
      };
    } catch (e) {
      return {
        'success': false, 
        'message': '${translate("common.error")}: $e'
      };
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