import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../Controllers/eventos_controller.dart';
import '../Widgets/calendar_widget.dart';
import '../Widgets/eventos_card.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/app_bar.dart';
import '../Widgets/global_drawer.dart';

class CalendarScreen extends GetView<EventoController> {
  const CalendarScreen({super.key});

  void _fetchEventsForMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    controller.fetchCalendarEvents(firstDay, lastDay);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventsForMonth(DateTime.now());
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: StandardAppBar(title: translate('calendar.title')),
      endDrawer: const GlobalDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchEventsForMonth(DateTime.now());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: CalendarWidget(
                onDaySelected: (selectedDay, events) {
                  controller.selectedDayEvents.assignAll(events);
                },
                onPageChanged: (focusedDay) {
                  _fetchEventsForMonth(focusedDay);
                },
              ),
            ),
            Obx(() {
              for (var e in controller.selectedDayEvents) {
                e.participantes.length;
              }

              if (controller.isLoading.value &&
                  controller.calendarEvents.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.selectedDayEvents.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note_rounded,
                          size: 60,
                          color: context.theme.disabledColor.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translate('calendar.no_events_day'),
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final events = controller.selectedDayEvents;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index.isOdd) return const SizedBox(height: 12);
                    final eventIndex = index ~/ 2;
                    if (eventIndex >= events.length) {
                      return const SizedBox.shrink();
                    }

                    final event = events[eventIndex];
                    final currentUserId =
                        Get.find<AuthController>().currentUser.value?.id ?? '';
                    final bool isParticipant = event.participantes.any(
                      (p) => p.trim() == currentUserId.trim(),
                    );

                    return EventosCard(
                      key: ValueKey(
                        'card_${event.id}_${event.participantes.length}_$isParticipant',
                      ),
                      evento: event,
                      showParticipationStatus: true,
                    );
                  }, childCount: events.isEmpty ? 0 : events.length * 2 - 1),
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/crear_evento'),
        backgroundColor: context.theme.colorScheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 3),
    );
  }
}
