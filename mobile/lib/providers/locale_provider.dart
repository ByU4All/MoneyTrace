import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/daos/settings_dao.dart';
import '../l10n/strings.dart';
import 'database_provider.dart';

/// Manages app language (persisted to DB, synced with AppStrings).
class LocaleNotifier extends StateNotifier<String> {
  final SettingsDao _dao;

  LocaleNotifier(this._dao) : super('en') {
    _load();
  }

  Future<void> _load() async {
    final lang = await _dao.getLanguage();
    AppStrings.setLocale(lang);
    state = lang;
  }

  Future<void> setLocale(String locale) async {
    AppStrings.setLocale(locale);
    state = locale;
    await _dao.setLanguage(locale);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier(ref.watch(settingsDaoProvider));
});

/// Manages large text toggle (persisted to DB).
class LargeTextNotifier extends StateNotifier<bool> {
  final SettingsDao _dao;

  LargeTextNotifier(this._dao) : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await _dao.getLargeText();
  }

  Future<void> toggle() async {
    state = !state;
    await _dao.setLargeText(state);
  }

  Future<void> set(bool value) async {
    state = value;
    await _dao.setLargeText(value);
  }
}

final largeTextProvider = StateNotifierProvider<LargeTextNotifier, bool>((ref) {
  return LargeTextNotifier(ref.watch(settingsDaoProvider));
});
