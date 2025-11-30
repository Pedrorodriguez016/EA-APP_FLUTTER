import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Importar

class RefreshButton extends StatelessWidget {
  final VoidCallback onRefresh;
  final String? message;

  const RefreshButton({
    Key? key,
    required this.onRefresh,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        onRefresh();
        if (message != null) {
          Get.snackbar(
            translate('common.update'), // 'Actualizado'
            message!,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            borderRadius: 12,
          );
        }
      },
      backgroundColor: const Color(0xFF667EEA),
      child: const Icon(Icons.refresh, color: Colors.white),
    );
  }
}