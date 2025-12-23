import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import '../Controllers/chat_list_controller.dart';
import '../Widgets/navigation_bar.dart';
import '../Models/user.dart';
import '../Models/eventos.dart';

class ChatListScreen extends GetView<ChatListController> {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          translate('chat.list_title'),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: controller.loadData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.friendsList.isEmpty && controller.eventsList.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildFilterBar(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  if (controller.selectedFilter.value == ChatFilter.all ||
                      controller.selectedFilter.value == ChatFilter.events)
                    if (controller.eventsList.isNotEmpty) ...[
                      _buildSectionHeader(translate('chat.events_section')),
                      ...controller.eventsList
                          .map((event) => _buildEventTile(event, controller))
                          .toList(),
                      const SizedBox(height: 20),
                    ],
                  if (controller.selectedFilter.value == ChatFilter.all ||
                      controller.selectedFilter.value == ChatFilter.friends)
                    if (controller.friendsList.isNotEmpty) ...[
                      _buildSectionHeader(translate('chat.friends_section')),
                      ...controller.friendsList
                          .map((friend) => _buildFriendTile(friend, controller))
                          .toList(),
                    ],
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildFilterButton(
              label: translate('chat.filter_all'),
              filter: ChatFilter.all,
              isSelected: controller.selectedFilter.value == ChatFilter.all,
            ),
            const SizedBox(width: 8),
            _buildFilterButton(
              label: translate('chat.filter_friends'),
              filter: ChatFilter.friends,
              icon: Icons.person_outline,
              isSelected: controller.selectedFilter.value == ChatFilter.friends,
            ),
            const SizedBox(width: 8),
            _buildFilterButton(
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
    required String label,
    required ChatFilter filter,
    IconData? icon,
    required bool isSelected,
  }) {
    final Color primaryColor = const Color(0xFF667EEA);
    final Color activeColor = primaryColor;
    final Color inactiveColor = Colors.grey.shade200;

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
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEventTile(Evento event, ChatListController controller) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.event, color: Color(0xFF667EEA)),
      ),
      title: Text(
        event.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        translate('chat.event_group_subtitle'),
        style: TextStyle(color: Colors.grey[500], fontSize: 14),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () => controller.goToEventChat(event),
    );
  }

  Widget _buildFriendTile(User friend, ChatListController controller) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFF667EEA),
        child: Text(
          friend.username.substring(0, 2).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        friend.username,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        translate('chat.subtitle'),
        style: TextStyle(color: Colors.grey[500], fontSize: 14),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () => controller.goToChat(friend),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            translate("chat.empty_list"),
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
