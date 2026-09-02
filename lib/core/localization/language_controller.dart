import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

/// Notifier and Provider for app language state
class LanguageController extends ChangeNotifier {
  static const String _prefKey = 'app_language_code';
  String _currentLanguage = 'th';

  LanguageController() {
    _loadSavedLanguage();
  }

  String get currentLanguage => _currentLanguage;
  bool get isThai => _currentLanguage == 'th';
  bool get isEnglish => _currentLanguage == 'en';

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && (saved == 'th' || saved == 'en')) {
        _currentLanguage = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String langCode) async {
    if (_currentLanguage != langCode && (langCode == 'th' || langCode == 'en')) {
      _currentLanguage = langCode;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, langCode);
      } catch (_) {}
    }
  }

  /// Shorthand string localization helper
  String tr(String key) {
    return AppStrings.get(key, lang: _currentLanguage);
  }
}

/// Inherited notifier for global language injection
class LanguageProvider extends InheritedNotifier<LanguageController> {
  const LanguageProvider({
    super.key,
    required LanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static LanguageController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<LanguageProvider>();
    assert(provider != null, 'No LanguageProvider found in context');
    return provider!.notifier!;
  }
}
