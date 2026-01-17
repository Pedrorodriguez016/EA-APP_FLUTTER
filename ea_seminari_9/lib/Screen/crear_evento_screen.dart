import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import '../Models/eventos.dart';
import '../Controllers/eventos_controller.dart';
import '../utils/app_theme.dart';
import '../Widgets/address_autocomplete_field.dart';

class CrearEventoScreen extends GetView<EventoController> {
  const CrearEventoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditing.value
                ? translate('events.edit_title')
                : translate('events.create_title'),
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.theme.iconTheme.color,
          ),
          onPressed: () {
            controller.limpiarFormularioCrear();
            controller.isEditing.value = false;
            controller.editingEventoId.value = null;
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SELECTOR DE CATEGORÍA ---
            _buildSectionTitle(context, translate('events.field_category')),
            const SizedBox(height: 12),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedCategoria.value,
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
            const SizedBox(height: 24),

            // --- NUEVO WIDGET: Selector de Fecha ---
            _buildDatePicker(context),
            const SizedBox(height: 24),

            // --- TITLE ---
            _buildSectionTitle(context, translate('events.field_title')),
            const SizedBox(height: 12),
            _buildTextField(
              context,
              controller.tituloController,
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 24),

            // --- ADDRESS ---
            _buildSectionTitle(context, translate('events.field_address')),
            const SizedBox(height: 12),
            AddressAutocompleteField(
              controller: controller.direccionController,
              countryCode: 'es', // Puedes cambiar esto según el país
              onLocationSelected: (lat, lon) {
                controller.selectedLat.value = lat;
                controller.selectedLon.value = lon;
              },
            ),
            const SizedBox(height: 24),

            // --- SWITCH PRIVACIDAD ---
            Obx(
              () => SwitchListTile(
                title: Text(
                  translate('events_extra.private_event'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(translate('events_extra.private_subtitle')),
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
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    translate('events_extra.no_friends_to_invite'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      translate('events_extra.invite_friends'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

            const SizedBox(height: 24),

            // --- Campo de capacidad máxima (opcional) ---
            _buildSectionTitle(context, translate('events_extra.max_capacity')),
            const SizedBox(height: 12),
            _buildTextField(
              context,
              controller.capacidadMaximaController,
              icon: Icons.people_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                translate('events_extra.unlimited_capacity_hint'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryBtn,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.colorScheme.primary.withValues(
                        alpha: 0.4,
                      ),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    translate('events.save_btn'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (controller.isEditing.value) {
                      controller.actualizarEvento();
                    } else {
                      controller.crearEvento();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController ctrl, {
    int maxLines = 1,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Container(
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
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: context.textTheme.bodyLarge,
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: context.theme.colorScheme.primary.withValues(
                    alpha: 0.7,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, translate('events.field_date')),
        const SizedBox(height: 12),
        Obx(() {
          final bool isDateSelected = controller.selectedSchedule.value != null;
          String buttonText = translate('events.select_date_btn');
          if (isDateSelected) {
            final dt = controller.selectedSchedule.value!;
            final String minute = dt.minute.toString().padLeft(2, '0');
            buttonText =
                '${dt.day}/${dt.month}/${dt.year} - ${dt.hour}:$minute';
          }
          final Color activeColor = context.theme.colorScheme.primary;
          final Color inactiveColor = context.theme.hintColor;
          final Color textColor = isDateSelected ? activeColor : inactiveColor;

          return Container(
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.pickSchedule(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: textColor),
                      const SizedBox(width: 12),
                      Text(
                        buttonText,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isDateSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (isDateSelected)
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
