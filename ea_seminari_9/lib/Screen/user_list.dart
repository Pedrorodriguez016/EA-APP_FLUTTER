import 'package:ea_seminari_9/Controllers/user_controller.dart';
import 'package:ea_seminari_9/Widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Widgets/user_card.dart';
import '../Widgets/refresh_button.dart';

class UserListScreen extends GetView<UserController> {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CAMBIO: Fondo dinámico
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: StandardAppBar(title: translate('users.list_title')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.isLoading.value && controller.userList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              TextField(
                controller: controller.searchEditingController,
                // CAMBIO: Estilo del texto que se escribe
                style: context.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: translate('users.search_hint'),
                  // CAMBIO: Hint color dinámico
                  hintStyle: TextStyle(color: context.theme.hintColor),
                  // CAMBIO: Icono dinámico
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.theme.iconTheme.color,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide.none, // Quitamos borde para usar solo fill
                  ),
                  filled: true,
                  // CAMBIO: Fondo del input (Blanco en light, Gris oscuro en dark)
                  fillColor: context.theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
                onSubmitted: (value) => controller.searchUsers(value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.userList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.userList.isEmpty) {
                    return Center(
                      child: Text(
                        translate('users.empty_search'),
                        // CAMBIO: Texto legible en ambos temas
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.theme.hintColor,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: controller.scrollController,
                    itemCount: controller.userList.length + 1,
                    separatorBuilder: (c, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == controller.userList.length) {
                        return Obx(
                          () => controller.isMoreLoading.value
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        );
                      }
                      final user = controller.userList[index];
                      return UserCard(user: user);
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: RefreshButton(
        onRefresh: () => controller.refreshUsers(),
        message: translate('common.success'),
      ),
    );
  }
}
