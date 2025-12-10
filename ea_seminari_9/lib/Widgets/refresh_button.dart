import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';

class RefreshButton extends StatelessWidget {
  final VoidCallback onRefresh;
  final String? message;

  const RefreshButton({Key? key, required this.onRefresh, this.message})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        onRefresh();
        if (message != null) {
          Get.snackbar(
            translate('common.update'),
            message!,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor:
                context.theme.colorScheme.primary, // Dynamic primary color
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
        }
      },
      backgroundColor: context.theme.colorScheme.primary,
      child: const Icon(Icons.refresh_rounded, color: Colors.white),
    );
  }
}
