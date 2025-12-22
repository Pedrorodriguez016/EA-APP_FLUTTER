import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import '../Models/eventos.dart';
import '../Controllers/eventos_controller.dart';

class CrearEventoScreen extends GetView<EventoController> {
  const CrearEventoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Los controllers 'titulo' y 'descripcion' YA existen en el EventoController

    return Scaffold(
      appBar: AppBar(
        title: Text(translate('events.create_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.limpiarFormularioCrear();
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        // Añadido SingleChildScrollView para evitar overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate('events.field_title'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // MODIFICADO: Usa el controller de GetX
            TextField(controller: controller.tituloController),
            const SizedBox(height: 16),
            Text(
              translate('events.field_address'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // MODIFICADO: Usa el controller de GetX
            TextField(controller: controller.direccionController, maxLines: 3),
            const SizedBox(height: 16),

            // --- SELECTOR DE CATEGORÍA ---
            Text(
              translate('events.field_category'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedCategoria.value,
                hint: Text(translate('events.select_category_hint')),
                isExpanded: true,
                items: listaCategorias.map((String categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (newValue) {
                  controller.selectedCategoria.value = newValue;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // --- FIN SELECTOR ---

            // --- NUEVO WIDGET: Selector de Fecha ---
            _buildDatePicker(context),

            // --- FIN NUEVO WIDGET ---
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(translate('events.save_btn')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  // MODIFICADO: Llama al controller sin parámetros
                  controller.crearEvento();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NUEVO WIDGET HELPER PARA MOSTRAR EL BOTÓN DE FECHA ---
  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('events.field_date'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Obx re-dibuja este widget cuando 'selectedSchedule' cambia
        Obx(() {
          final bool isDateSelected = controller.selectedSchedule.value != null;

          // Formatea la fecha para mostrarla
          String buttonText = translate('events.select_date_btn');
          if (isDateSelected) {
            final dt = controller.selectedSchedule.value!;
            // Formato simple: 13/11/2025 - 23:50
            final String minute = dt.minute.toString().padLeft(2, '0');
            buttonText =
                "${dt.day}/${dt.month}/${dt.year} - ${dt.hour}:$minute";
          }

          return OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 20),
            label: Text(buttonText),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48), // Ancho completo
              alignment: Alignment.centerLeft,
              foregroundColor: isDateSelected
                  ? Colors.black87
                  : Colors.grey.shade700,
              side: BorderSide(
                color: isDateSelected ? Colors.blue : Colors.grey.shade400,
              ),
            ),
            onPressed: () {
              // Llama a la función del controlador para abrir el picker
              controller.pickSchedule(context);
            },
          );
        }),
      ],
    );
  }
}
