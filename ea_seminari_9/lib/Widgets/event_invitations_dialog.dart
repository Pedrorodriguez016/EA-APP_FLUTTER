import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Models/eventos.dart';
import 'event_invitation_card.dart';

class EventInvitationsDialog {
  static void show(
    BuildContext context, {
    required RxList<Evento> invitations,
    required void Function(Evento, bool) onRespond,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: context.theme.cardTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            titlePadding: const EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: 12,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.secondary.withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: context.theme.colorScheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    translate('invitations.title'),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.6),
                child: Obx(() {
                  if (invitations.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 48,
                            color: context.theme.disabledColor.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            translate('invitations.empty_msg'),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: invitations.length,
                    itemBuilder: (ctx, index) {
                      final evento = invitations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventInvitationCard(
                          evento: evento,
                          onAccept: () {
                            onRespond(evento, true);
                            if (invitations.length == 1) Get.back();
                          },
                          onReject: () {
                            onRespond(evento, false);
                            if (invitations.length == 1) Get.back();
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            actionsPadding: const EdgeInsets.all(24),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: context.theme.colorScheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: Text(translate('common.close').toUpperCase()),
              ),
            ],
          ),
        );
      },
    );
  }
}
