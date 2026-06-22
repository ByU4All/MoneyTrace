import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/events.dart';
import '../data/database.dart';
import '../l10n/strings.dart';
import '../providers/database_provider.dart';
import '../providers/dashboard_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart' show formatAmount;
import 'history_screen.dart' show historyProvider;
import 'accounts_screen.dart' show accountsProvider;

/// Event creation screen with type tabs.
class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  final Set<String> _selectedFriendIds = {};
  String? _selectedAccountId;
  String? _selectedFromAccountId;
  String? _selectedToAccountId;
  DateTime _eventDate = DateTime.now();

  List<Friend> _friends = [];
  bool _isSplit = false;
  final Map<String, TextEditingController> _splitControllers = {};

  // Tab-to-event-type mapping (keys for l10n)
  static const _tabKeys = [
    ('tab_expense', EventType.expense),
    ('tab_income', EventType.income),
    ('tab_transfer', EventType.transfer),
    ('tab_i_owe', EventType.liability),
    ('tab_owes_me', EventType.receivable),
    ('tab_settle', null), // Determined by sub-selection
  ];

  bool _isSettlePaid = true; // For settle tab
  String? _selectedPhotoPath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabKeys.length, vsync: this);
    _loadFriends();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    for (final c in _splitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final friends = await ref.read(friendDaoProvider).getFriends();
    if (mounted) setState(() => _friends = friends);
  }

  void _initSplitControllers() {
    for (final c in _splitControllers.values) {
      c.dispose();
    }
    _splitControllers.clear();
    if (_selectedFriendIds.isEmpty) return;
    final amountRupees = double.tryParse(_amountController.text.trim()) ?? 0;
    final totalPaise = (amountRupees * 100).round();
    final n = _selectedFriendIds.length;
    final share = n > 0 ? (totalPaise ~/ n) : 0;
    for (final id in _selectedFriendIds) {
      _splitControllers[id] = TextEditingController(
        text: (share / 100).toStringAsFixed(2),
      );
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
    if (_selectedPhotoPath != null) {
      final old = File(_selectedPhotoPath!);
      if (await old.exists()) await old.delete();
    }
    if (mounted) setState(() => _selectedPhotoPath = dest);
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

  EventType get _currentEventType {
    final idx = _tabController.index;
    if (idx == 5) {
      return _isSettlePaid
          ? EventType.settlementPaid
          : EventType.settlementReceived;
    }
    return _tabKeys[idx].$2!;
  }

  bool get _needsFriend {
    final t = _currentEventType;
    return t == EventType.liability ||
        t == EventType.receivable ||
        t == EventType.settlementPaid ||
        t == EventType.settlementReceived;
  }

  bool get _needsCategory {
    return _currentEventType == EventType.expense;
  }

  bool get _needsTransferAccounts {
    return _currentEventType == EventType.transfer;
  }

  bool get _requiresAccount {
    final t = _currentEventType;
    return t == EventType.expense ||
        t == EventType.income ||
        t == EventType.settlementPaid ||
        t == EventType.settlementReceived ||
        t == EventType.creditCardPayment ||
        t == EventType.emiPayment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('add_transaction')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          onTap: (_) => setState(() {
            _isSplit = false;
          }),
          tabs: _tabKeys.map((t) => Tab(text: AppStrings.get(t.$1))).toList(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Settle sub-selection
            if (_tabController.index == 5)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(AppStrings.get('i_paid'))),
                    ButtonSegment(value: false, label: Text(AppStrings.get('i_received'))),
                  ],
                  selected: {_isSettlePaid},
                  onSelectionChanged: (v) =>
                      setState(() => _isSettlePaid = v.first),
                ),
              ),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: AppStrings.get('amount'),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              autofocus: true,
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
                future: ref
                    .read(databaseProvider)
                    .select(ref.read(databaseProvider).categories)
                    .get(),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('category'),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(
                              value: c.name,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  );
                },
              ),

            // Split bill toggle — expense only, shown BEFORE friend picker
            if (_currentEventType == EventType.expense) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.call_split, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Split bill',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                  Switch(
                    value: _isSplit,
                    onChanged: (v) => setState(() {
                      _isSplit = v;
                      if (v) _initSplitControllers();
                    }),
                  ),
                ],
              ),
            ],

            // Friend tagging — shown when required (liability/settle) or split is ON
            if (_needsFriend || (_currentEventType == EventType.expense && _isSplit)) ...[
              const SizedBox(height: 16),
              Column(
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
                            if (_isSplit) _initSplitControllers();
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
            ],

            // Split amounts — expense only, when split ON
            if (_currentEventType == EventType.expense && _isSplit) ...[
              if (_selectedFriendIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 28),
                  child: Text(
                    'Select friends above to split with',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                )
              else ...[
                const SizedBox(height: 8),
                ..._splitControllers.entries.map((entry) {
                  final friendName = _friends
                      .where((f) => f.id == entry.key)
                      .map((f) => f.name)
                      .firstOrNull ?? '?';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 28),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            friendName,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: entry.value,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              prefixText: '₹ ',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 2),
                  child: Text(
                    'Each friend owes you their share',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ],

            // Transfer accounts
            if (_needsTransferAccounts) ...[
              const SizedBox(height: 16),
              FutureBuilder(
                future: ref.read(accountDaoProvider).getAccounts(),
                builder: (context, snapshot) {
                  final accounts = snapshot.data ?? [];
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedFromAccountId,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('from_account'),
                          prefixIcon: const Icon(Icons.account_balance),
                        ),
                        items: accounts
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedFromAccountId = v),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedToAccountId,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('to_account'),
                          prefixIcon: const Icon(Icons.account_balance),
                        ),
                        items: accounts
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedToAccountId = v),
                      ),
                    ],
                  );
                },
              ),
            ],

            // Account (for non-transfer types)
            if (!_needsTransferAccounts) ...[
              const SizedBox(height: 16),
              FutureBuilder(
                future: ref.read(accountDaoProvider).getAccounts(),
                builder: (context, snapshot) {
                  final accounts = snapshot.data ?? [];
                  if (_requiresAccount && accounts.length == 1 && _selectedAccountId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedAccountId = accounts.first.id);
                    });
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    decoration: InputDecoration(
                      labelText: _requiresAccount
                          ? AppStrings.get('account_required')
                          : AppStrings.get('account_optional'),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    items: [
                      if (!_requiresAccount)
                        DropdownMenuItem(
                            value: null, child: Text(AppStrings.get('no_account'))),
                      ...accounts.map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedAccountId = v),
                  );
                },
              ),
            ],

            // Date picker
            const SizedBox(height: 16),
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

            // Complete a pending recurring
            if (_currentEventType == EventType.expense ||
                _currentEventType == EventType.emiPayment ||
                _currentEventType == EventType.income) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.repeat, size: 16),
                  label: Text(AppStrings.get('complete_a_recurring')),
                  onPressed: _showPendingRecurring,
                ),
              ),
            ],

            // Bill photo
            const SizedBox(height: 16),
            if (_selectedPhotoPath != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedPhotoPath!),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPhotoPath = null),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _showPhotoSourceSheet,
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Change photo'),
              ),
            ] else
              OutlinedButton.icon(
                onPressed: _showPhotoSourceSheet,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Attach Bill Photo'),
              ),

            const SizedBox(height: 24),

            // Submit
            ElevatedButton(
              onPressed: _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  AppStrings.get('add_transaction'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPendingRecurring() async {
    final recurringDao = ref.read(recurringDaoProvider);
    final items = await recurringDao.getRecurring();
    final pending = items.where((r) => r.isAutopay != 1).toList();

    if (!mounted) return;
    if (pending.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('no_pending_recurring'))),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppStrings.get('select_recurring'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...pending.map((rec) => ListTile(
                title: Text(rec.name),
                subtitle: Text('${formatAmount(rec.amount)} • ${rec.frequency}'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _amountController.text = (rec.amount / 100).toString();
                    _descriptionController.text = rec.name;
                    _selectedCategory = rec.category;
                    _selectedAccountId = rec.accountId;
                  });
                },
              )),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('please_enter_amount'))),
      );
      return;
    }

    final amountRupees = double.tryParse(amountText);
    if (amountRupees == null || amountRupees <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('invalid_amount'))),
      );
      return;
    }

    if (_requiresAccount && !_needsTransferAccounts && _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('please_select_account'))),
      );
      return;
    }

    if (_needsTransferAccounts &&
        (_selectedFromAccountId == null || _selectedToAccountId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('please_select_both_accounts'))),
      );
      return;
    }

    if (_needsFriend && _selectedFriendIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('friend'))),
      );
      return;
    }

    final amountPaise = (amountRupees * 100).round();
    final dateStr =
        '${_eventDate.year}-${_eventDate.month.toString().padLeft(2, '0')}-${_eventDate.day.toString().padLeft(2, '0')}';

    try {
      final eventDao = ref.read(eventDaoProvider);
      final friendList = _selectedFriendIds.toList();
      final primaryFriendId =
          _needsFriend && friendList.isNotEmpty ? friendList.first : null;

      final eventId = await eventDao.createEvent(
        type: _currentEventType.value,
        amount: amountPaise,
        category: _needsCategory ? _selectedCategory : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        friendId: primaryFriendId,
        accountId: _needsTransferAccounts ? null : _selectedAccountId,
        fromAccountId: _needsTransferAccounts ? _selectedFromAccountId : null,
        toAccountId: _needsTransferAccounts ? _selectedToAccountId : null,
        eventDate: dateStr,
        billPhotoPath: _selectedPhotoPath,
      );

      if (friendList.isNotEmpty) {
        await eventDao.tagFriends(eventId, friendList);
      }

      // Auto-create RECEIVABLE events for split amounts
      if (_isSplit && _currentEventType == EventType.expense) {
        final desc = _descriptionController.text.trim();
        for (final entry in _splitControllers.entries) {
          final splitRupees = double.tryParse(entry.value.text.trim()) ?? 0;
          if (splitRupees <= 0) continue;
          final splitPaise = (splitRupees * 100).round();
          final receivableId = await eventDao.createEvent(
            type: EventType.receivable.value,
            amount: splitPaise,
            friendId: entry.key,
            description: desc.isNotEmpty ? 'Split: $desc' : 'Split',
            eventDate: dateStr,
          );
          await eventDao.tagFriends(receivableId, [entry.key]);
        }
      }

      // Update account balances
      if (_needsTransferAccounts) {
        final accountDao = ref.read(accountDaoProvider);
        if (_selectedFromAccountId != null) {
          await accountDao.updateBalance(_selectedFromAccountId!, -amountPaise);
        }
        if (_selectedToAccountId != null) {
          await accountDao.updateBalance(_selectedToAccountId!, amountPaise);
        }
      } else if (_selectedAccountId != null) {
        final accountDao = ref.read(accountDaoProvider);
        final etype = _currentEventType;
        if (etype == EventType.expense ||
            etype == EventType.settlementPaid ||
            etype == EventType.creditCardPayment ||
            etype == EventType.emiPayment) {
          await accountDao.updateBalance(_selectedAccountId!, -amountPaise);
        } else if (etype == EventType.income ||
            etype == EventType.settlementReceived) {
          await accountDao.updateBalance(_selectedAccountId!, amountPaise);
        }
      }

      ref.invalidate(dashboardProvider);
      ref.invalidate(historyProvider);
      ref.invalidate(accountsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get('transaction_added'))),
        );
        Navigator.pop(context);
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
