import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final Function(DateTime)? onDateSelected;

  const CustomDatePicker({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = now;

    DateTime? currentSelection;
    // Intentar parsear el valor actual para inicializar el calendario
    if (controller.text.isNotEmpty) {
      try {
        // Primero intentamos formato ISO (yyyy-MM-dd)
        currentSelection = DateTime.parse(controller.text);
      } catch (_) {
        try {
          // Si falla, intentamos parsear el formato "bonito" si fuera necesario,
          // o simplemente usamos la fecha por defecto si no podemos reconstruirlo.
          // Para simplificar, si no es ISO, dejamos que use initialDate.
        } catch (_) {}
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentSelection ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale(
        'es',
        'ES',
      ), // Adjust as needed or use system default
      builder: (context, child) {
        return Theme(
          data: context.theme.copyWith(
            colorScheme: context.theme.colorScheme.copyWith(
              primary:
                  context.theme.colorScheme.primary, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: context.theme.colorScheme.onSurface, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    context.theme.colorScheme.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Mostrar formato bonito al usuario: "14 de enero de 1999"
      final String prettyDate = DateFormat(
        "d 'de' MMMM 'de' y",
        'es_ES',
      ).format(picked);
      controller.text = prettyDate;

      // Devolver la fecha real ISO o el objeto DateTime via callback si se proporciona
      if (onDateSelected != null) {
        onDateSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: context.textTheme.bodyLarge,
        onTap: () => _selectDate(context),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          fillColor: context.isDarkMode
              ? context.theme.colorScheme.surface.withValues(alpha: 0.5)
              : Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: context.theme.colorScheme.primary),
          ),
          prefixIcon: Icon(
            prefixIcon ?? Icons.cake_rounded,
            color: context.theme.colorScheme.primary,
          ),
          suffixIcon: Icon(
            suffixIcon ?? Icons.calendar_today_rounded,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
