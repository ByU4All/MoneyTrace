import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
import '../providers/database_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _budgetController = TextEditingController();
  final _resetDayController = TextEditingController();
  final _carryOverCapController = TextEditingController();
  bool _carryOverEnabled = false;
  bool _carryOverNegative = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsDao = ref.read(settingsDaoProvider);
    final baseBudget = await settingsDao.getBaseBudget();
    final resetDay = await settingsDao.getBudgetResetDay();
    final carryOverEnabled = await settingsDao.getCarryOverEnabled();
    final carryOverCap = await settingsDao.getCarryOverCap();
    final carryOverNegative = await settingsDao.getCarryOverNegative();

    setState(() {
      _budgetController.text = (baseBudget / 100).toString();
      _resetDayController.text = resetDay.toString();
      _carryOverEnabled = carryOverEnabled;
      _carryOverCapController.text = carryOverCap > 0 ? (carryOverCap / 100).toString() : '';
      _carryOverNegative = carryOverNegative;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _budgetController.dispose();
    _resetDayController.dispose();
    _carryOverCapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('settings')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(text: AppStrings.get('general')),
            Tab(text: AppStrings.get('categories')),
            Tab(text: AppStrings.get('data')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildCategoriesTab(),
          _buildDataTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    final locale = ref.watch(localeProvider);
    final largeText = ref.watch(largeTextProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Display section
          Text(AppStrings.get('display'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: locale,
            decoration: InputDecoration(labelText: AppStrings.get('language')),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
            ],
            onChanged: (v) {
              if (v != null) {
                ref.read(localeProvider.notifier).setLocale(v);
              }
            },
          ),
          SwitchListTile(
            title: Text(AppStrings.get('larger_text')),
            value: largeText,
            activeColor: AppColors.accent,
            onChanged: (v) => ref.read(largeTextProvider.notifier).set(v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Budget section
          Text(AppStrings.get('budget_settings'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(
            controller: _budgetController,
            decoration: InputDecoration(labelText: AppStrings.get('monthly_budget')),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _resetDayController,
            decoration: InputDecoration(labelText: AppStrings.get('reset_day')),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(AppStrings.get('carry_over_balance')),
            subtitle: Text(AppStrings.get('carry_over_subtitle')),
            value: _carryOverEnabled,
            activeColor: AppColors.accent,
            onChanged: (v) => setState(() => _carryOverEnabled = v),
          ),
          if (_carryOverEnabled) ...[
            TextField(
              controller: _carryOverCapController,
              decoration: InputDecoration(labelText: AppStrings.get('carry_over_cap')),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(AppStrings.get('carry_negative')),
              value: _carryOverNegative,
              activeColor: AppColors.accent,
              onChanged: (v) => setState(() => _carryOverNegative = v),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSettings,
            child: Text(AppStrings.get('save_settings')),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final db = ref.watch(databaseProvider);
    final categoryNameCtrl = TextEditingController();

    return FutureBuilder(
      future: db.select(db.categories).get(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: categoryNameCtrl,
                      decoration: InputDecoration(hintText: AppStrings.get('new_category_name')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final name = categoryNameCtrl.text.trim();
                      if (name.isEmpty) return;
                      await db.into(db.categories).insert(CategoriesCompanion.insert(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                      ));
                      categoryNameCtrl.clear();
                      setState(() {});
                    },
                    child: Text(AppStrings.get('add')),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    title: Text(cat.name),
                    trailing: cat.isDefault == 0
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.danger),
                            onPressed: () async {
                              await (db.delete(db.categories)
                                    ..where((c) => c.id.equals(cat.id)))
                                  .go();
                              setState(() {});
                            },
                          )
                        : Text(AppStrings.get('default_label'), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.get('backup'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            label: Text(AppStrings.get('export_data')),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get('export_data_subtitle'),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),
          Text(AppStrings.get('restore'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _importData,
            icon: const Icon(Icons.upload),
            label: Text(AppStrings.get('import_data')),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get('import_data_subtitle'),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),


          const SizedBox(height: 24),
          Text(AppStrings.get('danger_zone'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.danger)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _clearData,
            icon: const Icon(Icons.delete_forever),
            label: Text(AppStrings.get('clear_all_data')),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get('clear_data_subtitle'),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final settingsDao = ref.read(settingsDaoProvider);
    final budget = double.tryParse(_budgetController.text);
    final resetDay = int.tryParse(_resetDayController.text);

    if (budget == null || resetDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('invalid_values'))),
      );
      return;
    }

    await settingsDao.setBaseBudget((budget * 100).round());
    await settingsDao.setBudgetResetDay(resetDay.clamp(1, 28));
    await settingsDao.setCarryOverEnabled(_carryOverEnabled);

    if (_carryOverEnabled) {
      final cap = double.tryParse(_carryOverCapController.text) ?? 0;
      await settingsDao.setCarryOverCap((cap * 100).round());
      await settingsDao.setCarryOverNegative(_carryOverNegative);
    }

    ref.invalidate(dashboardProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('settings_saved'))),
      );
    }
  }

  Future<Directory> _getBackupDir() async {
    final backupDir = Directory('/storage/emulated/0/Download/MoneyTrace');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<void> _exportData() async {
    try {
      final dataDao = ref.read(dataDaoProvider);
      final data = await dataDao.exportAll();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

      final backupDir = await _getBackupDir();
      final date = DateTime.now().toIso8601String().split('T')[0];
      final time = DateTime.now().toIso8601String().split('T')[1].replaceAll(':', '-').split('.')[0];
      final file = File('${backupDir.path}/moneytrace_backup_${date}_$time.json');
      await file.writeAsString(jsonStr);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.format('backup_saved', [file.path])),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.format('export_failed', ['$e']))),
        );
      }
    }
  }

  Future<void> _importData() async {
    final backupDir = await _getBackupDir();
    final backupFiles = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path)); // newest first

    if (!mounted) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.get('import_backup'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (backupFiles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(AppStrings.get('no_backups_found'), style: const TextStyle(color: AppColors.textMuted)),
              )
            else
              ...backupFiles.take(10).map((f) {
                final name = f.path.split('/').last;
                return ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(name, style: const TextStyle(fontSize: 13)),
                  dense: true,
                  onTap: () => Navigator.pop(ctx, f.path),
                );
              }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(AppStrings.get('browse_other_files')),
              dense: true,
              onTap: () => Navigator.pop(ctx, '_browse_'),
            ),
          ],
        ),
      ),
    );

    if (selected == null || !mounted) return;

    try {
      String jsonStr;

      if (selected == '_browse_') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
          withData: true,
        );
        if (result == null) return;
        final file = result.files.single;
        if (file.bytes != null) {
          jsonStr = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          jsonStr = await File(file.path!).readAsString();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.get('could_not_read_file'))),
            );
          }
          return;
        }
      } else {
        jsonStr = await File(selected).readAsString();
      }

      final data = json.decode(jsonStr) as Map<String, dynamic>;

      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.get('import_data_q')),
          content: Text(AppStrings.get('import_data_warning')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.get('cancel'))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: Text(AppStrings.get('import')),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final dataDao = ref.read(dataDaoProvider);
      await dataDao.importAll(data);

      ref.invalidate(dashboardProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get('data_imported'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.format('import_failed', ['$e']))),
        );
      }
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('clear_all_data_q')),
        content: Text(AppStrings.get('clear_data_warning')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.get('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(AppStrings.get('clear')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final dataDao = ref.read(dataDaoProvider);
      await dataDao.clearAllData();
      ref.invalidate(dashboardProvider);
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get('all_data_cleared'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.format('error', ['$e']))),
        );
      }
    }
  }
}
