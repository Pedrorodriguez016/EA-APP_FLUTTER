import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import '../Services/user_services.dart';
import '../Services/eventos_services.dart';
import '../Controllers/auth_controller.dart';
import '../Models/user.dart';
import '../Models/eventos.dart';
import '../utils/logger.dart';

enum ChatFilter { all, friends, events }

class ChatListController extends GetxController {
  final UserServices _userServices;
  final EventosServices _eventosServices;
  final AuthController _authController;

  ChatListController(
    this._userServices,
    this._eventosServices,
    this._authController,
  );

  var friendsList = <User>[].obs;
  var eventsList = <Evento>[].obs;
  var isLoading = true.obs;
  var selectedFilter = ChatFilter.all.obs;

  void setFilter(ChatFilter filter) {
    selectedFilter.value = filter;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() async {
    try {
      isLoading(true);
      final myId = _authController.currentUser.value?.id;
      logger.i('👥 Cargando lista de chats (amigos y eventos)');

      if (myId != null) {
        // Cargar amigos
        final friendsData = await _userServices.fetchFriends(myId);
        List<User> friends = friendsData['friends'];
        friendsList.assignAll(friends);

        // Cargar eventos (donde estoy apuntado)
        final misEventos = await _eventosServices.getMisEventos();
        // Combinamos creados e inscritos, ya que en ambos se puede chatear
        final List<Evento> combined = [
          ...misEventos['creados']!,
          ...misEventos['inscritos']!,
        ];
        // Eliminamos duplicados por si acaso
        final uniqueIds = <String>{};
        eventsList.assignAll(
          combined.where((e) => uniqueIds.add(e.id)).toList(),
        );

        logger.i(
          '✅ Chats cargados: ${friends.length} amigos, ${eventsList.length} eventos',
        );
      } else {
        logger.w('⚠️ Usuario no autenticado, no se pueden cargar amigos');
      }
    } catch (e) {
      logger.e('❌ Error cargando chats', error: e);
      Get.snackbar(
        translate('common.error'),
        translate('chat.errors.load_contacts'),
      );
    } finally {
      isLoading(false);
    }
  }

  void goToChat(User friend) {
    logger.i('💬 Abriendo chat con: ${friend.username}');
    Get.toNamed(
      '/chat',
      arguments: {
        'friendId': friend.id,
        'friendName': friend.username,
        'friendPhoto': friend.profilePhoto,
      },
    );
  }

  void goToEventChat(Evento event) {
    logger.i('🏟️ Abriendo chat de evento: ${event.name}');
    Get.toNamed(
      '/event-chat',
      arguments: {'eventId': event.id, 'eventName': event.name},
    );
  }
}
