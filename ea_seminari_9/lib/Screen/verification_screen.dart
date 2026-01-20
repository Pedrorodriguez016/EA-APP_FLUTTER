import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../utils/app_theme.dart';
import '../Models/user.dart';
import '../Services/auth_service.dart';
import '../Services/storage_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController otpController = TextEditingController();
  late String email;
  String? password;
  String? username;

  // Timer state
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _canResend = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      email = args['email'] ?? '';
      password = args['password'];
      username = args['username'];
    } else {
      email = args ?? '';
    }

    if (email.isEmpty) {
      // Fallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar('Error', translate('common.error'));
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _handleVerify() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      Get.snackbar(
        translate('auth.verification.error_title'),
        translate(
          'auth.verification.error_invalid_code',
        ), // Use translation key if available or generic text
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await authController.verifyOtp(email, otp);
    setState(() => _isLoading = false);

    if (success) {
      if (password != null &&
          password!.isNotEmpty &&
          username != null &&
          username!.isNotEmpty) {
        // Frontend auto-login simulation
        try {
          // Perform login with USERNAME (as required by backend) and PASSWORD
          final authService =
              Get.find<
                AuthService
              >(); // Already in controller but accessing directly is fine
          final data = await authService.login(
            username!,
            password!,
          ); // Login with email/user and password

          final userData = data['user'];
          final user = User.fromJson({
            ...userData,
            'token': data['token'],
            'refreshToken': data['refreshToken'],
          });

          // Update AuthController state
          authController.currentUser.value = user;
          authController.token = data['token'];
          authController.refreshToken = data['refreshToken'];
          authController.isLoggedIn.value = true;

          // Save session
          final storage = Get.find<StorageService>();
          await storage.saveSession(user);

          Get.offAllNamed('/questionnaire');

          return; // Exit
        } catch (e) {
          // If auto-login fails, fall back to manual login
          Get.offAllNamed('/login');
        }
      } else {
        // Fallback if no password passed
        Get.offAllNamed('/login');
      }
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;

    final success = await authController.resendCode(email);
    if (success) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.darkSpaceBg : AppGradients.lightBg,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Header Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      size: 40,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  translate('auth.verification.title'),
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  "${translate('auth.verification.subtitle')}\n$email",
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // OTP Input (Simplified as a single styled text field for robustness)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                      hintText: "------",
                      hintStyle: TextStyle(
                        letterSpacing: 8,
                        color: context.theme.disabledColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Verify Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryBtn,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            translate('auth.verification.verify_btn'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Resend Link
                Center(
                  child: TextButton(
                    onPressed: _canResend ? _handleResend : null,
                    child: Text(
                      _canResend
                          ? translate('auth.verification.resend_btn')
                          : "${translate('auth.verification.resend_timer')}${_secondsRemaining}s",
                      style: TextStyle(
                        color: _canResend
                            ? context.theme.colorScheme.primary
                            : context.theme.disabledColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Back to Login option
                Center(
                  child: TextButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    child: Text(
                      translate(
                        'auth.login.action_btn',
                      ), // "Iniciar Sesión" or similar
                      style: TextStyle(
                        color: context.theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
