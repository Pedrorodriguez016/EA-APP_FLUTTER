import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../Controllers/user_controller.dart';
import '../Controllers/eventos_controller.dart';
import '../Widgets/user_card.dart';
import '../Widgets/solicitudes.dart';
import '../Widgets/event_invitations_dialog.dart';
import 'friends_bottomsheet.dart';
import '../utils/app_theme.dart';

class GlobalDrawer extends StatelessWidget {
  const GlobalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userController = Get.find<UserController>();
    final eventoController = Get.find<EventoController>();
    final user = authController.currentUser.value;
    final isDark = context.isDarkMode;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: const BoxDecoration(gradient: AppGradients.primaryBtn),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? translate('common.user'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.gmail ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: translate('settings.title'),
                  onTap: () {
                    Get.back(); // Close drawer
                    Get.toNamed('/settings');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title:
                      translate('settings.theme_mode') == 'settings.theme_mode'
                      ? 'Tema'
                      : translate('settings.theme_mode'),
                  trailing: Switch(
                    value: isDark,
                    activeThumbColor: context.theme.colorScheme.primary,
                    onChanged: (val) {
                      Get.changeThemeMode(
                        val ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                  onTap: () {},
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),

                // Friends Section
                _buildFriendsSection(context, userController),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),

                // Event Invitations Section
                _buildEventInvitationsSection(context, eventoController),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: translate('dialogs.logout.title'),
                  color: context.theme.colorScheme.error,
                  onTap: () {
                    Get.back(); // Close drawer
                    authController.logout();
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                color: context.theme.hintColor.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsSection(
    BuildContext context,
    UserController userController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translate('home.friends_section.title'),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    userController.friendsList.length.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.group_add_rounded,
          title: translate('home.friends_section.requests_btn'),
          onTap: () {
            FriendRequestsDialog.show(
              context,
              requests: userController.friendsRequests,
              onAccept: (user) => userController.acceptFriendRequest(user),
              onReject: (user) => userController.rejectFriendRequest(user),
            );
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.search_rounded,
          title: translate('home.friends_section.search_btn'),
          onTap: () {
            Get.back();
            Get.toNamed('/users');
          },
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (userController.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (userController.friendsList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                translate('home.friends_section.empty_msg'),
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: userController.friendsList.length > 2
                    ? 2
                    : userController.friendsList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: UserCard(user: userController.friendsList[index]),
                  );
                },
              ),
              if (userController.friendsList.length > 2 ||
                  userController.friendsCurrentPage.value <
                      userController.friendsTotalPages.value)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextButton(
                    onPressed: () {
                      Get.back(); // Cierra el Drawer
                      FriendsBottomSheet.show(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ver todos mis amigos',
                          style: TextStyle(
                            color: context.theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: context.theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildEventInvitationsSection(
    BuildContext context,
    EventoController eventoController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translate('invitations.title'),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.secondary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    eventoController.misInvitaciones.length.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.event_note_rounded,
          title: translate('invitations.pending'),
          onTap: () {
            EventInvitationsDialog.show(
              context,
              invitations: eventoController.misInvitaciones,
              onRespond: (evento, accept) =>
                  eventoController.respondToInvitation(evento, accept),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? context.theme.iconTheme.color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color ?? context.theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: context.theme.hintColor,
          ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
