import 'package:drift/drift.dart';

import '../database.dart';

/// Typed settings access layer.
class SettingsDao {
  final AppDatabase _db;
  const SettingsDao(this._db);

  Future<String?> _get(String key) async {
    final row = await (_db.select(_db.settings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _set(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }

  // Base budget (in paise)
  Future<int> getBaseBudget() async {
    final v = await _get('base_budget');
    return v != null ? int.parse(v) : 1000000; // Default ₹10,000
  }

  Future<void> setBaseBudget(int value) => _set('base_budget', value.toString());

  // Budget reset day
  Future<int> getBudgetResetDay() async {
    final v = await _get('budget_reset_day');
    return v != null ? int.parse(v) : 1;
  }

  Future<void> setBudgetResetDay(int value) => _set('budget_reset_day', value.toString());

  // Budget reset enabled
  Future<bool> getBudgetResetEnabled() async {
    final v = await _get('budget_reset_enabled');
    return v == 'true' || v == '1';
  }

  Future<void> setBudgetResetEnabled(bool value) =>
      _set('budget_reset_enabled', value ? 'true' : 'false');

  // Carry over enabled
  Future<bool> getCarryOverEnabled() async {
    final v = await _get('carry_over_enabled');
    return v == 'true' || v == '1';
  }

  Future<void> setCarryOverEnabled(bool value) =>
      _set('carry_over_enabled', value ? 'true' : 'false');

  // Carry over cap (in paise)
  Future<int> getCarryOverCap() async {
    final v = await _get('carry_over_cap');
    return v != null ? int.parse(v) : 0;
  }

  Future<void> setCarryOverCap(int value) => _set('carry_over_cap', value.toString());

  // Carry over negative
  Future<bool> getCarryOverNegative() async {
    final v = await _get('carry_over_negative');
    return v == 'true' || v == '1';
  }

  Future<void> setCarryOverNegative(bool value) =>
      _set('carry_over_negative', value ? 'true' : 'false');

  // Last reset date
  Future<String?> getLastResetDate() => _get('last_reset_date');

  Future<void> setLastResetDate(String value) => _set('last_reset_date', value);

  // Language
  Future<String> getLanguage() async {
    final v = await _get('language');
    return v ?? 'en';
  }

  Future<void> setLanguage(String value) => _set('language', value);

  // Large text
  Future<bool> getLargeText() async {
    final v = await _get('large_text');
    return v == 'true' || v == '1';
  }

  Future<void> setLargeText(bool value) =>
      _set('large_text', value ? 'true' : 'false');

  // Onboarding complete
  Future<bool> getOnboardingComplete() async {
    final v = await _get('onboarding_complete');
    return v == 'true';
  }

  Future<void> setOnboardingComplete(bool value) =>
      _set('onboarding_complete', value ? 'true' : 'false');

  // Get all settings as a map
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'base_budget': await getBaseBudget(),
      'budget_reset_day': await getBudgetResetDay(),
      'budget_reset_enabled': await getBudgetResetEnabled(),
      'carry_over_enabled': await getCarryOverEnabled(),
      'carry_over_cap': await getCarryOverCap(),
      'carry_over_negative': await getCarryOverNegative(),
    };
  }
}
