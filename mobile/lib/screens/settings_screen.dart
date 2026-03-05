import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';
import '../providers/database_provider.dart';
import '../providers/dashboard_provider.dart';
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
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Categories'),
            Tab(text: 'Data'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Budget Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(
            controller: _budgetController,
            decoration: const InputDecoration(labelText: 'Monthly Budget (\u20B9)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _resetDayController,
            decoration: const InputDecoration(labelText: 'Reset Day (1-28)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Carry Over Balance'),
            subtitle: const Text('Carry unused budget to next month'),
            value: _carryOverEnabled,
            activeColor: AppColors.accent,
            onChanged: (v) => setState(() => _carryOverEnabled = v),
          ),
          if (_carryOverEnabled) ...[
            TextField(
              controller: _carryOverCapController,
              decoration: const InputDecoration(labelText: 'Carry Over Cap (\u20B9, 0 = unlimited)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Carry Negative Balance'),
              value: _carryOverNegative,
              activeColor: AppColors.accent,
              onChanged: (v) => setState(() => _carryOverNegative = v),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
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
                      decoration: const InputDecoration(hintText: 'New category name'),
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
                    child: const Text('Add'),
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
                        : const Text('Default', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
          const Text('Backup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            label: const Text('Export Data'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight),
          ),
          const SizedBox(height: 4),
          const Text(
            'Download your data as JSON for backup',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),
          const Text('Restore', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _importData,
            icon: const Icon(Icons.upload),
            label: const Text('Import Data'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight),
          ),
          const SizedBox(height: 4),
          const Text(
            'Restore from a JSON backup file (replaces all data)',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),
          const Text('Danger Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.danger)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _clearData,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Clear All Data'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          ),
          const SizedBox(height: 4),
          const Text(
            'Delete all transactions (keeps settings & categories)',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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
        const SnackBar(content: Text('Invalid values')),
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
        const SnackBar(content: Text('Settings saved!')),
      );
    }
  }

  Future<Directory> _getBackupDir() async {
    final extDir = await getExternalStorageDirectory();
    final backupDir = Directory('${extDir!.path}/backups');
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
            content: Text('Backup saved to ${file.path}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
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
            const Text('Import Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (backupFiles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No backups found', style: TextStyle(color: AppColors.textMuted)),
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
              title: const Text('Browse other files...'),
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
              const SnackBar(content: Text('Could not read file')),
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
          title: const Text('Import Data?'),
          content: const Text('This will replace ALL existing data with the backup. This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Import'),
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
          const SnackBar(content: Text('Data imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all transactions and month records. Settings and categories will be kept.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final dataDao = ref.read(dataDaoProvider);
      await dataDao.clearAllData();
      ref.invalidate(dashboardProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
