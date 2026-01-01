import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../Controllers/eventos_controller.dart';

class CrearEventoScreen extends GetView<EventoController> {
  const CrearEventoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Los controllers 'titulo' y 'descripcion' YA existen en el EventoController

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento'),
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
            const Text(
              'Título del evento',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // MODIFICADO: Usa el controller de GetX
            TextField(controller: controller.tituloController),
            const SizedBox(height: 16),
            const Text(
              'Direccion',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // MODIFICADO: Usa el controller de GetX
            TextField(controller: controller.direccionController, maxLines: 3),
            const SizedBox(height: 16),

            _buildDatePicker(context),

            // --- FIN NUEVO WIDGET ---
            const SizedBox(height: 16),

            // --- SWITCH PRIVACIDAD ---
            Obx(
              () => SwitchListTile(
                title: const Text(
                  'Evento Privado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Solo los invitados podrán ver y unirse a este evento',
                ),
                value: controller.isPrivate.value,
                onChanged: (bool val) {
                  controller.isPrivate.value = val;
                  if (val) {
                    controller.fetchFriends();
                  }
                },
              ),
            ),

            // --- LISTA DE PROBABLES INVITADOS ---
            Obx(() {
              if (!controller.isPrivate.value) return const SizedBox.shrink();

              if (controller.isLoadingFriends.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.friendsList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No tienes amigos para invitar aún.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Invitar amigos:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 200, // Altura fija para la lista
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.friendsList.length,
                      itemBuilder: (context, index) {
                        final friend = controller.friendsList[index];
                        return Obx(() {
                          final isSelected = controller.selectedInvitedUsers
                              .contains(friend.id);
                          return CheckboxListTile(
                            title: Text(friend.username),
                            subtitle: Text(friend.gmail),
                            value: isSelected,
                            onChanged: (_) =>
                                controller.toggleUserSelection(friend.id),
                          );
                        });
                      },
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            // --- Campo de capacidad máxima (siempre visible, opcional) ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Capacidad máxima (opcional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: controller.capacidadMaximaController,
                  keyboardType: TextInputType.number,
                  placeholder: 'Dejar en blanco para capacidad ilimitada',
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.person_2,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Si no ingresas un número, el evento tendrá capacidad ilimitada',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar evento'),
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
        const Text(
          'Fecha y hora del evento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Obx re-dibuja este widget cuando 'selectedSchedule' cambia
        Obx(() {
          final bool isDateSelected = controller.selectedSchedule.value != null;

          // Formatea la fecha para mostrarla
          String buttonText = 'Seleccionar fecha y hora';
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
