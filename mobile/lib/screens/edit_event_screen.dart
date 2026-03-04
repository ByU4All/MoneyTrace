import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/engine.dart';
import '../data/database.dart';
import '../providers/database_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/modal_sheet.dart';

/// Shows an edit bottom sheet for an existing event.
Future<bool?> showEditEventSheet(BuildContext context, WidgetRef ref, Event event) {
  return showAppModalSheet<bool>(
    context: context,
    title: 'Edit Transaction',
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
  String? _selectedFriendId;
  String? _selectedAccountId;
  String? _selectedFromAccountId;
  String? _selectedToAccountId;
  late DateTime _eventDate;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _amountController = TextEditingController(text: (e.amount / 100).toString());
    _descriptionController = TextEditingController(text: e.description ?? '');
    _selectedType = e.type;
    _selectedCategory = e.category;
    _selectedFriendId = e.friendId;
    _selectedAccountId = e.accountId;
    _selectedFromAccountId = e.fromAccountId;
    _selectedToAccountId = e.toAccountId;
    _eventDate = DateTime.parse(e.eventDate);
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
          decoration: const InputDecoration(
            labelText: 'Amount (\u20B9)',
            prefixIcon: Icon(Icons.currency_rupee),
          ),
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
            future: ref.read(databaseProvider).select(ref.read(databaseProvider).categories).get(),
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
                  items: categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
              );
            },
          ),

        // Friend
        if (_needsFriend)
          FutureBuilder(
            future: ref.read(friendDaoProvider).getFriends(),
            builder: (context, snapshot) {
              final friends = snapshot.data ?? [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedFriendId,
                  decoration: const InputDecoration(labelText: 'Friend', prefixIcon: Icon(Icons.person)),
                  items: friends.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                  onChanged: (v) => setState(() => _selectedFriendId = v),
                ),
              );
            },
          ),

        // Transfer accounts
        if (_isTransfer)
          FutureBuilder(
            future: ref.read(accountDaoProvider).getAccounts(),
            builder: (context, snapshot) {
              final accounts = snapshot.data ?? [];
              return Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedFromAccountId,
                    decoration: const InputDecoration(labelText: 'From Account', prefixIcon: Icon(Icons.account_balance)),
                    items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (v) => setState(() => _selectedFromAccountId = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedToAccountId,
                    decoration: const InputDecoration(labelText: 'To Account', prefixIcon: Icon(Icons.account_balance)),
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
                  decoration: const InputDecoration(labelText: 'Account', prefixIcon: Icon(Icons.account_balance)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('No account')),
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
            decoration: const InputDecoration(
              labelText: 'Date',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              '${_eventDate.year}-${_eventDate.month.toString().padLeft(2, '0')}-${_eventDate.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _save,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Save Changes', style: TextStyle(fontSize: 16)),
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
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Save Changes?',
      message: 'This will update the transaction and adjust account balances.',
      confirmText: 'Save',
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
      await eventDao.updateEvent(
        old.id,
        type: _selectedType,
        amount: newAmountPaise,
        category: _needsCategory ? _selectedCategory : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        friendId: _needsFriend ? _selectedFriendId : null,
        accountId: _isTransfer ? null : _selectedAccountId,
        fromAccountId: _isTransfer ? _selectedFromAccountId : null,
        toAccountId: _isTransfer ? _selectedToAccountId : null,
        eventDate: newDateStr,
      );

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction updated!')),
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
