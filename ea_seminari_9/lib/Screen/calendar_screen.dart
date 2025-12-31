import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../Controllers/eventos_controller.dart';
import '../Widgets/calendar_widget.dart';
import '../Widgets/eventos_card.dart';
import '../Widgets/navigation_bar.dart';
import '../Widgets/app_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final EventoController controller = Get.find<EventoController>();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventsForMonth(_focusedDay);
    });
  }

  void _fetchEventsForMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    controller.fetchCalendarEvents(firstDay, lastDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: StandardAppBar(title: translate('calendar.title')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CalendarWidget(
              onDaySelected: (selectedDay, events) {
                controller.selectedDayEvents.assignAll(events);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _fetchEventsForMonth(focusedDay);
              },
            ),
          ),
          Obx(() {
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

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index.isOdd) return const SizedBox(height: 12);
                  final eventIndex = index ~/ 2;
                  final event = controller.selectedDayEvents[eventIndex];
                  final currentUserId =
                      Get.find<AuthController>().currentUser.value?.id ?? '';
                  final bool isParticipant = event.participantes.any(
                    (p) => p.trim() == currentUserId.trim(),
                  );

                  return EventosCard(
                    // La clave cambia si cambia el ID, si cambia el número de participantes o si cambia tu estado
                    key: ValueKey(
                      'card_${event.id}_${event.participantes.length}_${isParticipant}',
                    ),
                    evento: event,
                    showParticipationStatus: true,
                  );
                }, childCount: controller.selectedDayEvents.length * 2 - 1),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 1),
    );
  }
}
