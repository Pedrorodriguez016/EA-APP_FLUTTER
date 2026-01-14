import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Services/user_services.dart';
import '../Controllers/eventos_controller.dart';
import '../Controllers/auth_controller.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({Key? key}) : super(key: key);

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final UserServices _userServices = UserServices();

  final Map<String, List<String>> _categoryMap = {
    'Deportes': [
      'Fútbol',
      'Baloncesto',
      'Tenis',
      'Pádel',
      'Running',
      'Ciclismo',
      'Natación',
      'Yoga',
      'Gimnasio',
      'Senderismo',
    ],
    'Música': [
      'Concierto Rock',
      'Concierto Pop',
      'Concierto Clásica',
      'Jazz',
      'Electrónica',
      'Hip Hop',
      'Karaoke',
      'Festival Musical',
    ],
    'Tecnología': [
      'Gaming',
      'eSports',
      'Programación',
      'Inteligencia Artificial',
      'Blockchain',
      'Startups',
      'Hackathon',
      'Meetup Tech',
    ],
    'Gastronomía': [
      'Restaurante',
      'Tapas',
      'Cocina Internacional',
      'Vinos',
      'Cerveza Artesanal',
      'Repostería',
      'Brunch',
      'Food Truck',
    ],
    'Cultura': [
      'Exposición Arte',
      'Teatro',
      'Cine',
      'Museo',
      'Literatura',
      'Fotografía',
      'Pintura',
      'Danza',
    ],
    'Social': [
      'Discoteca',
      'After Work',
      'Networking',
      'Speed Dating',
      'Fiesta Temática',
      'Cumpleaños',
    ],
    'Salud': ['Meditación', 'Spa', 'Wellness', 'Mindfulness', 'Salud Mental'],
    'Aire Libre': ['Camping', 'Montañismo', 'Playa', 'Barbacoa', 'Picnic'],
  };

  final List<String> _selectedInterests = [];
  String? _expandedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingInterests();
  }

  void _loadExistingInterests() {
    if (Get.isRegistered<AuthController>()) {
      final user = Get.find<AuthController>().currentUser.value;
      if (user?.interests != null) {
        setState(() {
          _selectedInterests.addAll(user!.interests!);
        });
      }
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_expandedCategory == category) {
        _expandedCategory = null;
      } else {
        _expandedCategory = category;
      }
    });
  }

  Future<void> _saveInterests() async {
    if (_selectedInterests.isEmpty) {
      Get.snackbar(
        translate('common.error'),
        'Por favor selecciona al menos un interés',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _userServices.updateInterests(_selectedInterests);

    if (success) {
      // Refrescar datos del usuario en el AuthController
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().fetchCurrentUser();
      }

      if (Get.isRegistered<EventoController>()) {
        Get.find<EventoController>().fetchRecommended();
      }

      setState(() => _isLoading = false);
      Get.offAllNamed('/home');
    } else {
      setState(() => _isLoading = false);
      Get.snackbar(
        translate('common.error'),
        'No se pudieron guardar los intereses',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.theme.colorScheme.primary.withOpacity(0.8),
              context.theme.colorScheme.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildSelectedCount(context),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: _categoryMap.keys
                              .map((cat) => _buildCategorySection(context, cat))
                              .toList(),
                        ),
                      ),
                      _buildBottomActions(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Personaliza tu feed',
                style: context.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dinos qué te apasiona para ofrecerte los mejores eventos.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCount(BuildContext context) {
    if (_selectedInterests.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${_selectedInterests.length} intereses seleccionados',
          style: TextStyle(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String category) {
    final isExpanded = _expandedCategory == category;
    final subInterests = _categoryMap[category]!;
    final selectedInCat = subInterests
        .where((i) => _selectedInterests.contains(i))
        .length;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isExpanded
                ? context.theme.colorScheme.primary.withOpacity(0.05)
                : context.theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded
                  ? context.theme.colorScheme.primary
                  : context.theme.dividerColor.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              // Botón de selección para la categoría general
              IconButton(
                onPressed: () => _toggleInterest(category),
                icon: Icon(
                  _selectedInterests.contains(category)
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: _selectedInterests.contains(category)
                      ? context.theme.colorScheme.primary
                      : context.theme.hintColor.withOpacity(0.5),
                ),
                tooltip: 'Seleccionar todo ${category}',
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _toggleCategory(category),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _selectedInterests.contains(category)
                                ? context.theme.colorScheme.primary
                                : null,
                          ),
                        ),
                        if (selectedInCat > 0 ||
                            _selectedInterests.contains(category))
                          Text(
                            _selectedInterests.contains(category)
                                ? 'Toda la categoría seleccionada'
                                : '$selectedInCat sub-intereses seleccionados',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.theme.colorScheme.primary,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _toggleCategory(category),
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: context.theme.hintColor,
                ),
              ),
            ],
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (_) => _toggleInterest(interest),
                  selectedColor: context.theme.colorScheme.primary.withOpacity(
                    0.2,
                  ),
                  checkmarkColor: context.theme.colorScheme.primary,
                  backgroundColor: context.theme.cardColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? context.theme.colorScheme.primary
                        : context.theme.colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? context.theme.colorScheme.primary
                          : context.theme.dividerColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveInterests,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Guardar Preferencias',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Get.offAllNamed('/home'),
            child: Text(
              'Omitir por ahora',
              style: TextStyle(color: context.theme.hintColor),
            ),
          ),
        ],
      ),
    );
  }
}
