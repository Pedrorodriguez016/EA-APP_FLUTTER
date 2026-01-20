import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class LanguagePreferences implements ITranslatePreferences {
  static const String _selectedLocaleKey = 'selected_locale';

  @override
  Future<Locale?> getPreferredLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_selectedLocaleKey);
    return localeCode != null ? Locale(localeCode) : null;
  }

  @override
  Future savePreferredLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLocaleKey, locale.languageCode);
  }
}
