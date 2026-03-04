import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/events.dart';
import '../providers/database_provider.dart';
import '../providers/dashboard_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart' show formatAmount;

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
  String? _selectedFriendId;
  String? _selectedAccountId;
  String? _selectedFromAccountId;
  String? _selectedToAccountId;
  DateTime _eventDate = DateTime.now();

  // Tab-to-event-type mapping
  static const _tabs = [
    ('Expense', EventType.expense),
    ('Income', EventType.income),
    ('Transfer', EventType.transfer),
    ('I Owe', EventType.liability),
    ('Owes Me', EventType.receivable),
    ('Settle', null), // Determined by sub-selection
  ];

  bool _isSettlePaid = true; // For settle tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  EventType get _currentEventType {
    final idx = _tabController.index;
    if (idx == 5) {
      return _isSettlePaid
          ? EventType.settlementPaid
          : EventType.settlementReceived;
    }
    return _tabs[idx].$2!;
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
        title: const Text('Add Transaction'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          onTap: (_) => setState(() {}),
          tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
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
                  segments: const [
                    ButtonSegment(value: true, label: Text('I Paid')),
                    ButtonSegment(value: false, label: Text('I Received')),
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
              decoration: const InputDecoration(
                labelText: 'Amount (\u20B9)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.notes),
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
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
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

            // Friend (for liability/receivable/settlement)
            if (_needsFriend) ...[
              const SizedBox(height: 16),
              FutureBuilder(
                future: ref.read(friendDaoProvider).getFriends(),
                builder: (context, snapshot) {
                  final friends = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedFriendId,
                    decoration: const InputDecoration(
                      labelText: 'Friend',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: friends
                        .map((f) => DropdownMenuItem(
                              value: f.id,
                              child: Text(f.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedFriendId = v),
                  );
                },
              ),
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
                        decoration: const InputDecoration(
                          labelText: 'From Account',
                          prefixIcon: Icon(Icons.account_balance),
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
                        decoration: const InputDecoration(
                          labelText: 'To Account',
                          prefixIcon: Icon(Icons.account_balance),
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
                  // Auto-select if required and only 1 account
                  if (_requiresAccount && accounts.length == 1 && _selectedAccountId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedAccountId = accounts.first.id);
                    });
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    decoration: InputDecoration(
                      labelText: _requiresAccount ? 'Account (required)' : 'Account (optional)',
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    items: [
                      if (!_requiresAccount)
                        const DropdownMenuItem(
                            value: null, child: Text('No account')),
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
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_eventDate.year}-${_eventDate.month.toString().padLeft(2, '0')}-${_eventDate.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),

            // Complete a pending recurring (for expense/emi tabs)
            if (_currentEventType == EventType.expense || _currentEventType == EventType.emiPayment) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.repeat, size: 16),
                  label: const Text('Complete a Recurring?'),
                  onPressed: () => _showPendingRecurring(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Submit
            ElevatedButton(
              onPressed: _submit,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Add Transaction', style: TextStyle(fontSize: 16)),
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
    // Filter to manual (non-autopay) recurring matching current type
    final typeStr = _currentEventType.value;
    final pending = items.where((r) => r.type == typeStr && r.isAutopay != 1).toList();

    if (!mounted) return;
    if (pending.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending recurring transactions')),
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
          const Text('Select Recurring', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...pending.map((rec) => ListTile(
            title: Text(rec.name),
            subtitle: Text('${formatAmount(rec.amount)} \u2022 ${rec.frequency}'),
            onTap: () {
              Navigator.pop(ctx);
              // Pre-fill form
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
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amountRupees = double.tryParse(amountText);
    if (amountRupees == null || amountRupees <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    // Validate required account
    if (_requiresAccount && !_needsTransferAccounts && _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    // Validate transfer accounts
    if (_needsTransferAccounts && (_selectedFromAccountId == null || _selectedToAccountId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both From and To accounts')),
      );
      return;
    }

    final amountPaise = (amountRupees * 100).round();
    final dateStr =
        '${_eventDate.year}-${_eventDate.month.toString().padLeft(2, '0')}-${_eventDate.day.toString().padLeft(2, '0')}';

    try {
      final eventDao = ref.read(eventDaoProvider);
      await eventDao.createEvent(
        type: _currentEventType.value,
        amount: amountPaise,
        category: _needsCategory ? _selectedCategory : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        friendId: _needsFriend ? _selectedFriendId : null,
        accountId: _needsTransferAccounts ? null : _selectedAccountId,
        fromAccountId: _needsTransferAccounts ? _selectedFromAccountId : null,
        toAccountId: _needsTransferAccounts ? _selectedToAccountId : null,
        eventDate: dateStr,
      );

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added!')),
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
