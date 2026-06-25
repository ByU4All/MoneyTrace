import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/engine.dart';
import '../data/database.dart';
import '../l10n/strings.dart';
import '../providers/database_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/friend_history_provider.dart';
import '../theme/colors.dart';
import '../widgets/bill_photo_strip.dart';
import '../widgets/modal_sheet.dart';
import '../widgets/empty_picker_row.dart';
import 'history_screen.dart' show historyProvider;
import 'accounts_screen.dart' show accountsProvider;

/// Shows an edit bottom sheet for an existing event.
Future<bool?> showEditEventSheet(BuildContext context, WidgetRef ref, Event event) {
  return showAppModalSheet<bool>(
    context: context,
    title: AppStrings.get('edit_transaction'),
    child: _EditEventForm(event: event),
  );
}

class _EditEventForm extends ConsumerStatefulWidget {
  final Event event;
  const _EditEventForm({required this.event});

  @override
  ConsumerState<_EditEventForm> createState() => _EditEventFormState();
}

class _EditEventFormState extends ConsumerState<_EditEventForm> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  String? _selectedCategory;
  final Set<String> _selectedFriendIds = {};
  String? _selectedAccountId;
  String? _selectedFromAccountId;
  String? _selectedToAccountId;
  late DateTime _eventDate;
  // Multi-photo: parallel lists; _existingPhotoIds[i] is null for new (not yet in DB) photos.
  final List<String> _photoPaths = [];
  final List<String?> _existingPhotoIds = [];
  final Set<String> _removedPhotoIds = {};
  final Set<String> _removedPhotoPaths = {};
  List<Friend> _friends = [];

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _amountController = TextEditingController(text: (e.amount / 100).toString());
    _descriptionController = TextEditingController(text: e.description ?? '');
    _selectedType = e.type;
    _selectedCategory = e.category;
    if (e.friendId != null) _selectedFriendIds.add(e.friendId!);
    _selectedAccountId = e.accountId;
    _selectedFromAccountId = e.fromAccountId;
    _selectedToAccountId = e.toAccountId;
    _eventDate = DateTime.parse(e.eventDate);

    _loadFriends();
    _loadPhotos();

    // Pull existing multi-tags into the chip selection.
    () async {
      final tagged = await ref.read(eventDaoProvider).getTaggedFriends(e.id);
      if (mounted) {
        setState(() => _selectedFriendIds.addAll(tagged));
      }
    }();
  }

  Future<void> _loadFriends() async {
    final friends = await ref.read(friendDaoProvider).getFriends();
    if (mounted) setState(() => _friends = friends);
  }

  Future<void> _loadPhotos() async {
    final photos = await ref.read(billPhotoDaoProvider).getPhotosForEvent(widget.event.id);
    if (mounted) {
      setState(() {
        _photoPaths.clear();
        _existingPhotoIds.clear();
        for (final p in photos) {
          _photoPaths.add(p.filePath);
          _existingPhotoIds.add(p.id);
        }
      });
    }
  }

  Future<void> _showAddFriendDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => const _AddFriendDialog(),
    );
    if (!mounted) return;
    if (name == null || name.isEmpty) return;
    await ref.read(friendDaoProvider).createFriend(name: name);
    if (mounted) _loadFriends();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null || !mounted) return;
    final dir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${dir.path}/receipts');
    if (!await receiptsDir.exists()) await receiptsDir.create(recursive: true);
    final dest = '${receiptsDir.path}/${const Uuid().v4()}.jpg';
    await File(picked.path).copy(dest);
    if (mounted) {
      setState(() {
        _photoPaths.add(dest);
        _existingPhotoIds.add(null);
      });
    }
  }

  void _removePhoto(int index) {
    final existingId = _existingPhotoIds[index];
    final path = _photoPaths[index];
    if (existingId != null) {
      _removedPhotoIds.add(existingId);
      _removedPhotoPaths.add(path);
    } else {
      // Newly added, not yet in DB — delete the file immediately since cancelling is fine
      File(path).exists().then((exists) { if (exists) File(path).delete(); });
    }
    setState(() {
      _photoPaths.removeAt(index);
      _existingPhotoIds.removeAt(index);
    });
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () { Navigator.pop(ctx); _pickPhoto(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () { Navigator.pop(ctx); _pickPhoto(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isTransfer => _selectedType == 'transfer';

  bool get _needsFriend {
    return _selectedType == 'liability' ||
        _selectedType == 'receivable' ||
        _selectedType == 'settlement_paid' ||
        _selectedType == 'settlement_received';
  }

  bool get _needsCategory => _selectedType == 'expense';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Amount
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: AppStrings.get('amount'),
            prefixIcon: const Icon(Icons.currency_rupee),
          ),
        ),
        const SizedBox(height: 16),

        // Description
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: AppStrings.get('description_optional'),
            prefixIcon: const Icon(Icons.notes),
          ),
        ),
        const SizedBox(height: 16),

        // Category (for expenses)
        if (_needsCategory)
          FutureBuilder(
            future: ref.read(databaseProvider).select(ref.read(databaseProvider).categories).get(),
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: EmptyPickerRow(
                    icon: Icons.category_outlined,
                    label: 'No categories yet',
                    dialogTitle: 'No categories yet',
                    dialogMessage:
                        'You need at least one category to save this expense.\n\n'
                        'Go to: More → Settings → Categories\n\n'
                        'Default categories are added automatically on a fresh install.',
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(labelText: AppStrings.get('category'), prefixIcon: const Icon(Icons.category)),
                  items: categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
              );
            },
          ),

        // Friends — primary single for settlement-types, optional multi-tag for the rest.
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.people, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _needsFriend
                        ? AppStrings.get('friend')
                        : AppStrings.get('with_friends_optional'),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._friends.map((f) {
                    final selected = _selectedFriendIds.contains(f.id);
                    return FilterChip(
                      label: Text(f.name),
                      selected: selected,
                      onSelected: (on) => setState(() {
                        if (on) {
                          _selectedFriendIds.add(f.id);
                        } else {
                          _selectedFriendIds.remove(f.id);
                        }
                      }),
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: const Text('New'),
                    onPressed: _showAddFriendDialog,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Transfer accounts
        if (_isTransfer)
          FutureBuilder(
            future: ref.read(accountDaoProvider).getAccounts(),
            builder: (context, snapshot) {
              final accounts = snapshot.data ?? [];
              if (accounts.isEmpty) {
                return const EmptyPickerRow(
                  icon: Icons.account_balance_outlined,
                  label: 'No accounts yet',
                  dialogTitle: 'No accounts yet',
                  dialogMessage:
                      'A transfer requires at least two accounts.\n\n'
                      'Go to the Accounts tab (🏦) and tap + to add your accounts.\n\n'
                      'A Cash account is created automatically on a fresh install.',
                );
              }
              return Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedFromAccountId,
                    decoration: InputDecoration(labelText: AppStrings.get('from_account'), prefixIcon: const Icon(Icons.account_balance)),
                    items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (v) => setState(() => _selectedFromAccountId = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedToAccountId,
                    decoration: InputDecoration(labelText: AppStrings.get('to_account'), prefixIcon: const Icon(Icons.account_balance)),
                    items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (v) => setState(() => _selectedToAccountId = v),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

        // Account (non-transfer)
        if (!_isTransfer)
          FutureBuilder(
            future: ref.read(accountDaoProvider).getAccounts(),
            builder: (context, snapshot) {
              final accounts = snapshot.data ?? [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: InputDecoration(labelText: AppStrings.get('account'), prefixIcon: const Icon(Icons.account_balance)),
                  items: [
                    DropdownMenuItem(value: null, child: Text(AppStrings.get('no_account'))),
                    ...accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                  ],
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                ),
              );
            },
          ),

        // Date
        InkWell(
          onTap: _pickDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: AppStrings.get('date'),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              '${_eventDate.year}-${_eventDate.month.toString().padLeft(2, '0')}-${_eventDate.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),

        // Bill photos
        const SizedBox(height: 16),
        BillPhotoStrip(
          paths: _photoPaths,
          onAdd: _showPhotoSourceSheet,
          onRemove: _removePhoto,
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _save,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(AppStrings.get('save_changes'), style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    final amountRupees = double.tryParse(amountText);
    if (amountRupees == null || amountRupees <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('invalid_amount'))),
      );
      return;
    }

    final confirmed = await showConfirmDialog(
      context: context,
      title: AppStrings.get('save_changes_q'),
      message: AppStrings.get('save_changes_msg'),
      confirmText: AppStrings.get('save'),
    );
    if (!confirmed) return;

    final old = widget.event;
    final newAmountPaise = (amountRupees * 100).round();
    final newDateStr = '${_eventDate.year}-${_eventDate.month.toString().padLeft(2, '0')}-${_eventDate.day.toString().padLeft(2, '0')}';

    try {
      final accountDao = ref.read(accountDaoProvider);
      final eventDao = ref.read(eventDaoProvider);
      final auditDao = ref.read(auditDaoProvider);

      // 1. Reverse old balance impact
      if (old.type == 'transfer') {
        if (old.fromAccountId != null) {
          await accountDao.updateBalance(old.fromAccountId!, old.amount); // undo debit
        }
        if (old.toAccountId != null) {
          await accountDao.updateBalance(old.toAccountId!, -old.amount); // undo credit
        }
      } else if (old.accountId != null) {
        final oldImpact = balanceImpact(old.type, old.amount);
        if (oldImpact != 0) {
          await accountDao.updateBalance(old.accountId!, -oldImpact);
        }
      }

      // 2. Apply new balance impact
      if (_isTransfer) {
        if (_selectedFromAccountId != null) {
          await accountDao.updateBalance(_selectedFromAccountId!, -newAmountPaise);
        }
        if (_selectedToAccountId != null) {
          await accountDao.updateBalance(_selectedToAccountId!, newAmountPaise);
        }
      } else if (_selectedAccountId != null) {
        final newImpact = balanceImpact(_selectedType, newAmountPaise);
        if (newImpact != 0) {
          await accountDao.updateBalance(_selectedAccountId!, newImpact);
        }
      }

      // 3. Update event
      final friendList = _selectedFriendIds.toList();
      final primaryFriendId =
          _needsFriend && friendList.isNotEmpty ? friendList.first : null;

      await eventDao.updateEvent(
        old.id,
        type: _selectedType,
        amount: newAmountPaise,
        category: _needsCategory ? _selectedCategory : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        friendId: primaryFriendId,
        accountId: _isTransfer ? null : _selectedAccountId,
        fromAccountId: _isTransfer ? _selectedFromAccountId : null,
        toAccountId: _isTransfer ? _selectedToAccountId : null,
        eventDate: newDateStr,
      );

      // Handle photo changes
      final billPhotoDao = ref.read(billPhotoDaoProvider);
      for (final id in _removedPhotoIds) {
        await billPhotoDao.deletePhoto(id);
      }
      for (final path in _removedPhotoPaths) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
      for (var i = 0; i < _photoPaths.length; i++) {
        if (_existingPhotoIds[i] == null) {
          await billPhotoDao.addPhoto(old.id, _photoPaths[i]);
        }
      }

      await eventDao.tagFriends(old.id, friendList);

      // Sync split receivables: if this is an expense, update any auto-created
      // "Split: X" receivables to match the new description and/or date.
      if (old.type == 'expense') {
        final newDesc = _descriptionController.text.trim();
        final splits = await eventDao.findSplitReceivables(old.eventDate, old.description);
        for (final split in splits) {
          await eventDao.updateEvent(
            split.id,
            description: newDesc.isNotEmpty ? 'Split: $newDesc' : 'Split',
            eventDate: newDateStr,
          );
        }
      }

      if (old.friendId != null) {
        ref.invalidate(friendHistoryProvider(old.friendId!));
      }
      for (final fid in friendList) {
        ref.invalidate(friendHistoryProvider(fid));
      }

      // 4. Audit log
      await auditDao.createAuditLog(
        action: 'update',
        entityType: 'event',
        entityId: old.id,
        oldValues: jsonEncode({
          'type': old.type,
          'amount': old.amount,
          'category': old.category,
          'description': old.description,
          'account_id': old.accountId,
          'event_date': old.eventDate,
        }),
        newValues: jsonEncode({
          'type': _selectedType,
          'amount': newAmountPaise,
          'category': _selectedCategory,
          'description': _descriptionController.text.trim(),
          'account_id': _selectedAccountId,
          'event_date': newDateStr,
        }),
        isMoneyRelated: true,
      );

      // 5. Invalidate providers
      ref.invalidate(dashboardProvider);
      ref.invalidate(historyProvider);
      ref.invalidate(accountsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get('transaction_updated'))),
        );
        Navigator.pop(context, true);
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

class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog();

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: _ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
            child: Text(AppStrings.get('add')),
          ),
        ],
      );
}
