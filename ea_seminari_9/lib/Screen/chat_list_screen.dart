import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import '../Controllers/chat_list_controller.dart';
import '../Widgets/navigation_bar.dart';
import '../Models/user.dart';
import '../Models/eventos.dart';
import '../Widgets/global_drawer.dart';

class ChatListScreen extends GetView<ChatListController> {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true; // Permitir volver atrás
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            translate('chat.list_title'),
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: context.theme.scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: context.theme.iconTheme.color),
              onPressed: controller.loadData,
            ),
            Builder(
              builder: (scaffoldContext) => IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () => Scaffold.of(scaffoldContext).openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: const GlobalDrawer(),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.friendsList.isEmpty && controller.eventsList.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _buildFilterBar(context),
              Divider(height: 1, color: context.theme.dividerColor),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    if (controller.selectedFilter.value == ChatFilter.all ||
                        controller.selectedFilter.value == ChatFilter.events)
                      if (controller.eventsList.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          translate('chat.events_section'),
                        ),
                        ...controller.eventsList.map(
                          (event) =>
                              _buildEventTile(context, event, controller),
                        ),
                        const SizedBox(height: 20),
                      ],
                    if (controller.selectedFilter.value == ChatFilter.all ||
                        controller.selectedFilter.value == ChatFilter.friends)
                      if (controller.friendsList.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          translate('chat.friends_section'),
                        ),
                        ...controller.friendsList.map(
                          (friend) =>
                              _buildFriendTile(context, friend, controller),
                        ),
                      ],
                  ],
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar: CustomNavBar(currentIndex: 2),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildFilterButton(
              context: context,
              label: translate('chat.filter_all'),
              filter: ChatFilter.all,
              isSelected: controller.selectedFilter.value == ChatFilter.all,
            ),
            const SizedBox(width: 8),
            _buildFilterButton(
              context: context,
              label: translate('chat.filter_friends'),
              filter: ChatFilter.friends,
              icon: Icons.person_outline,
              isSelected: controller.selectedFilter.value == ChatFilter.friends,
            ),
            const SizedBox(width: 8),
            _buildFilterButton(
              context: context,
              label: translate('chat.filter_events'),
              filter: ChatFilter.events,
              icon: Icons.event_outlined,
              isSelected: controller.selectedFilter.value == ChatFilter.events,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required String label,
    required ChatFilter filter,
    IconData? icon,
    required bool isSelected,
  }) {
    final Color primaryColor = context.theme.colorScheme.primary;
    final Color activeColor = primaryColor;
    final Color inactiveColor = context.theme.dividerColor.withValues(
      alpha: 0.1,
    );

    return InkWell(
      onTap: () {
        controller.setFilter(filter);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : context.theme.iconTheme.color,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : context.theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: context.theme.hintColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEventTile(
    BuildContext context,
    Evento event,
    ChatListController controller,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.event, color: context.theme.colorScheme.primary),
      ),
      title: Text(
        event.name,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        translate('chat.event_group_subtitle'),
        style: TextStyle(color: context.theme.hintColor, fontSize: 14),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: context.theme.dividerColor,
      ),
      onTap: () => controller.goToEventChat(event),
    );
  }

  Widget _buildFriendTile(
    BuildContext context,
    User friend,
    ChatListController controller,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: context.theme.colorScheme.primary,
        child: Text(
          friend.username.length > 1
              ? friend.username.substring(0, 2).toUpperCase()
              : friend.username.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: context.theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        friend.username,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        translate('chat.subtitle'),
        style: TextStyle(color: context.theme.hintColor, fontSize: 14),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: context.theme.dividerColor,
      ),
      onTap: () => controller.goToChat(friend),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: context.theme.disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            translate('chat.empty_list'),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.hintColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
