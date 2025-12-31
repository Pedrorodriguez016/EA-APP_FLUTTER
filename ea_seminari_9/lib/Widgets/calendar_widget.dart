import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Models/eventos.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Controllers/auth_controller.dart';
import '../Controllers/eventos_controller.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime selectedDay, List<Evento> events) onDaySelected;
  final Function(DateTime focusedDay)? onPageChanged;

  const CalendarWidget({
    super.key,
    required this.onDaySelected,
    this.onPageChanged,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final EventoController controller = Get.find<EventoController>();

    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Obx(() {
        final allEvents = controller.calendarEvents;
        final eventsKey = allEvents
            .map((e) => '${e.id}:${e.participantes.length}')
            .join('_');

        List<Evento> getEventsForDay(DateTime day) {
          return allEvents.where((event) {
            try {
              final eventDate = DateTime.parse(event.schedule);
              return isSameDay(eventDate, day);
            } catch (e) {
              return false;
            }
          }).toList();
        }

        return TableCalendar<Evento>(
          key: ValueKey(eventsKey),
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          locale: LocalizedApp.of(context).delegate.currentLocale.toString(),
          eventLoader: getEventsForDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDaySelected(selectedDay, getEventsForDay(selectedDay));
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
            widget.onPageChanged?.call(focusedDay);
          },
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: context.theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: context.theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            formatButtonTextStyle: TextStyle(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox();

              final currentUserId =
                  Get.find<AuthController>().currentUser.value?.id;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: events.take(4).map((event) {
                  final isParticipant = event.participantes.any((p) {
                    if (currentUserId == null || currentUserId.isEmpty) {
                      return false;
                    }
                    return p.trim() == currentUserId.trim();
                  });
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isParticipant
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      }),
    );
  }
}
