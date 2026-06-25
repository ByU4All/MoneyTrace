import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/engine.dart';
import '../data/database.dart';
import '../l10n/strings.dart';
import '../providers/dashboard_provider.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import 'recurring_screen.dart' show recurringProvider;
import '../widgets/amount_display.dart';
import '../widgets/progress_bar.dart';

String _emiCountdownLabel(int emiDay) {
  final days = daysUntilNextEmi(emiDay: emiDay, now: DateTime.now());
  if (days == 0) return AppStrings.get('today');
  return AppStrings.format('days', ['$days']);
}

final loansProvider = FutureProvider.autoDispose<List<Loan>>((ref) async {
  return ref.watch(loanDaoProvider).getLoans();
});

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('loans'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLoanSheet(context, ref),
        tooltip: AppStrings.get('add_loan'),
        child: const Icon(Icons.add),
      ),
      body: loansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (loans) {
          if (loans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(AppStrings.get('no_active_loans'), style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  const Text('Tap + to add your first loan', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              final remaining = loan.tenureMonths - loan.paymentsMade;
              final progress = (loan.paymentsMade / loan.tenureMonths * 100).clamp(0, 100).toDouble();
              final outstanding = remaining * loan.emiAmount;

              return Card(
                child: InkWell(
                  onTap: () => _showLoanDetail(context, ref, loan),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(loan.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                            Text('${loan.interestRate}%', style: const TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppProgressBar(value: progress),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppStrings.format('emis_remaining', ['$remaining']), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            Text('${progress.round()}%', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get('emi'), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                Text(formatAmount(loan.emiAmount), style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(AppStrings.get('outstanding'), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                Text(formatAmount(outstanding), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${AppStrings.get('next_emi_in')}: ${_emiCountdownLabel(loan.emiDay)}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddLoanSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final principalCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final tenureCtrl = TextEditingController();
    final emiCtrl = TextEditingController();
    final emiDayCtrl = TextEditingController(text: '5');
    final lenderCtrl = TextEditingController();
    final paymentsMadeCtrl = TextEditingController(text: '0');
    String selectedType = 'personal_loan';
    DateTime loanStartDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.get('add_loan'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppStrings.get('loan_name'))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: AppStrings.get('type')),
                  items: [
                    DropdownMenuItem(value: 'home_loan', child: Text(AppStrings.loanTypeName('home_loan'))),
                    DropdownMenuItem(value: 'car_loan', child: Text(AppStrings.loanTypeName('car_loan'))),
                    DropdownMenuItem(value: 'personal_loan', child: Text(AppStrings.loanTypeName('personal_loan'))),
                    DropdownMenuItem(value: 'credit_card_emi', child: Text(AppStrings.loanTypeName('credit_card_emi'))),
                    DropdownMenuItem(value: 'bnpl', child: Text(AppStrings.loanTypeName('bnpl'))),
                    DropdownMenuItem(value: 'other', child: Text(AppStrings.loanTypeName('other'))),
                  ],
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: principalCtrl, decoration: InputDecoration(labelText: AppStrings.get('principal_amount')), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: rateCtrl, decoration: InputDecoration(labelText: AppStrings.get('interest_pct')), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: tenureCtrl, decoration: InputDecoration(labelText: AppStrings.get('tenure_months')), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: emiCtrl, decoration: InputDecoration(labelText: AppStrings.get('emi_amount')), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: emiDayCtrl, decoration: InputDecoration(labelText: AppStrings.get('emi_day')), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: lenderCtrl, decoration: InputDecoration(labelText: AppStrings.get('lender_optional')))),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: loanStartDate,
                      firstDate: DateTime(2015),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => loanStartDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: AppStrings.get('loan_start_date')),
                    child: Text(
                      '${loanStartDate.year}-${loanStartDate.month.toString().padLeft(2, '0')}-${loanStartDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paymentsMadeCtrl,
                  decoration: InputDecoration(labelText: AppStrings.get('emis_already_paid')),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final principal = double.tryParse(principalCtrl.text);
                    final rate = double.tryParse(rateCtrl.text);
                    final tenure = int.tryParse(tenureCtrl.text);
                    final emi = double.tryParse(emiCtrl.text);
                    final emiDay = int.tryParse(emiDayCtrl.text) ?? 5;

                    final paymentsMade = int.tryParse(paymentsMadeCtrl.text) ?? 0;

                    if (name.isEmpty || principal == null || rate == null || tenure == null || emi == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('please_fill_required'))),
                      );
                      return;
                    }

                    if (paymentsMade >= tenure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('emis_paid_less_tenure'))),
                      );
                      return;
                    }

                    final startDate = '${loanStartDate.year}-${loanStartDate.month.toString().padLeft(2, '0')}-${loanStartDate.day.toString().padLeft(2, '0')}';
                    final emiAmountPaise = (emi * 100).round();

                    final loanId = await ref.read(loanDaoProvider).createLoan(
                      name: name,
                      type: selectedType,
                      principal: (principal * 100).round(),
                      interestRate: rate,
                      tenureMonths: tenure,
                      emiAmount: emiAmountPaise,
                      startDate: startDate,
                      emiDay: emiDay,
                      lender: lenderCtrl.text.trim().isNotEmpty ? lenderCtrl.text.trim() : null,
                      paymentsMade: paymentsMade,
                    );

                    // Auto-create linked recurring EMI for remaining months
                    final now = DateTime.now();
                    final remainingMonths = tenure - paymentsMade;
                    final endMonth = now.month + remainingMonths;
                    final endDate = DateTime(now.year + (endMonth - 1) ~/ 12, (endMonth - 1) % 12 + 1, emiDay.clamp(1, 28));
                    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

                    // Compute nextDueDate for EMI
                    final emiDueThisMonth = DateTime(now.year, now.month, emiDay.clamp(1, 28));
                    final emiNextDue = emiDueThisMonth.isAfter(now) ? emiDueThisMonth : DateTime(now.year, now.month + 1, emiDay.clamp(1, 28));
                    final emiNextDueStr = '${emiNextDue.year}-${emiNextDue.month.toString().padLeft(2, '0')}-${emiNextDue.day.toString().padLeft(2, '0')}';

                    await ref.read(recurringDaoProvider).createRecurring(
                      name: '$name EMI',
                      type: 'emi_payment',
                      amount: emiAmountPaise,
                      frequency: 'monthly',
                      dayOfMonth: emiDay,
                      startDate: startDate,
                      endDate: endDateStr,
                      linkedLoanId: loanId,
                      nextDueDate: emiNextDueStr,
                    );

                    ref.invalidate(loansProvider);
                    ref.invalidate(dashboardProvider);
                    ref.invalidate(recurringProvider);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(AppStrings.get('add_loan')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoanDetail(BuildContext context, WidgetRef ref, Loan loan) {
    final progress = (loan.paymentsMade / loan.tenureMonths * 100).clamp(0, 100).toDouble();
    final totalPaid = loan.paymentsMade * loan.emiAmount;
    final outstanding = (loan.tenureMonths - loan.paymentsMade) * loan.emiAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text(loan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
              const SizedBox(height: 16),
              AppProgressBar(value: progress),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.format('of_emis_remaining', ['${loan.tenureMonths - loan.paymentsMade}', '${loan.tenureMonths}']), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text('${progress.round()}%', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow(AppStrings.get('principal'), formatAmount(loan.principal)),
              _detailRow(AppStrings.get('interest_rate'), '${loan.interestRate}%'),
              _detailRow(AppStrings.get('emi'), formatAmount(loan.emiAmount)),
              _detailRow(AppStrings.get('outstanding'), formatAmount(outstanding), valueColor: AppColors.danger),
              _detailRow(AppStrings.get('total_paid'), formatAmount(totalPaid), valueColor: AppColors.success),
              _detailRow(AppStrings.get('emi_day'), '${loan.emiDay}th'),
              _detailRow(AppStrings.get('next_emi_in'), _emiCountdownLabel(loan.emiDay)),
              if (loan.lender != null) _detailRow(AppStrings.get('lender'), loan.lender!),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditLoanSheet(context, ref, loan);
                },
                icon: const Icon(Icons.edit),
                label: Text(AppStrings.get('edit_loan')),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(AppStrings.get('close_loan_q')),
                      content: Text(AppStrings.get('mark_loan_inactive')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.get('cancel'))),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                          child: Text(AppStrings.get('close')),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(loanDaoProvider).closeLoan(loan.id);

                    // Deactivate linked recurring EMI
                    final recurrings = await ref.read(recurringDaoProvider).getRecurring();
                    for (final r in recurrings) {
                      if (r.linkedLoanId == loan.id) {
                        await ref.read(recurringDaoProvider).updateRecurring(r.id, isActive: false);
                      }
                    }

                    ref.invalidate(loansProvider);
                    ref.invalidate(dashboardProvider);
                    ref.invalidate(recurringProvider);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.close, color: AppColors.danger),
                label: Text(AppStrings.get('close_loan'), style: const TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditLoanSheet(BuildContext context, WidgetRef ref, Loan loan) {
    final nameCtrl = TextEditingController(text: loan.name);
    final principalCtrl = TextEditingController(text: (loan.principal / 100).toStringAsFixed(0));
    final rateCtrl = TextEditingController(text: loan.interestRate.toString());
    final tenureCtrl = TextEditingController(text: loan.tenureMonths.toString());
    final emiCtrl = TextEditingController(text: (loan.emiAmount / 100).toStringAsFixed(0));
    final emiDayCtrl = TextEditingController(text: loan.emiDay.toString());
    final lenderCtrl = TextEditingController(text: loan.lender ?? '');
    final paymentsMadeCtrl = TextEditingController(text: loan.paymentsMade.toString());
    final startParts = loan.startDate.split('-');
    DateTime loanStartDate = DateTime(
      int.parse(startParts[0]),
      int.parse(startParts[1]),
      int.parse(startParts[2]),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.get('edit_loan'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppStrings.get('loan_name'))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: principalCtrl, decoration: InputDecoration(labelText: AppStrings.get('principal_amount')), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: rateCtrl, decoration: InputDecoration(labelText: AppStrings.get('interest_pct')), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: tenureCtrl, decoration: InputDecoration(labelText: AppStrings.get('tenure_months')), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: emiCtrl, decoration: InputDecoration(labelText: AppStrings.get('emi_amount')), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: emiDayCtrl, decoration: InputDecoration(labelText: AppStrings.get('emi_day')), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: lenderCtrl, decoration: InputDecoration(labelText: AppStrings.get('lender_optional')))),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: loanStartDate,
                      firstDate: DateTime(2015),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => loanStartDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: AppStrings.get('loan_start_date')),
                    child: Text(
                      '${loanStartDate.year}-${loanStartDate.month.toString().padLeft(2, '0')}-${loanStartDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paymentsMadeCtrl,
                  decoration: InputDecoration(labelText: AppStrings.get('emis_already_paid')),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final principal = double.tryParse(principalCtrl.text);
                    final rate = double.tryParse(rateCtrl.text);
                    final tenure = int.tryParse(tenureCtrl.text);
                    final emi = double.tryParse(emiCtrl.text);
                    final emiDay = int.tryParse(emiDayCtrl.text) ?? loan.emiDay;
                    final paymentsMade = int.tryParse(paymentsMadeCtrl.text) ?? loan.paymentsMade;

                    if (name.isEmpty || principal == null || rate == null || tenure == null || emi == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('please_fill_required'))),
                      );
                      return;
                    }

                    if (paymentsMade >= tenure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('emis_paid_less_tenure'))),
                      );
                      return;
                    }

                    final startDate = '${loanStartDate.year}-${loanStartDate.month.toString().padLeft(2, '0')}-${loanStartDate.day.toString().padLeft(2, '0')}';
                    final emiAmountPaise = (emi * 100).round();

                    await ref.read(loanDaoProvider).updateLoan(
                      loan.id,
                      name: name,
                      principal: (principal * 100).round(),
                      interestRate: rate,
                      tenureMonths: tenure,
                      emiAmount: emiAmountPaise,
                      startDate: startDate,
                      emiDay: emiDay,
                      paymentsMade: paymentsMade,
                      lender: lenderCtrl.text.trim().isNotEmpty ? lenderCtrl.text.trim() : null,
                    );

                    // Update linked recurring EMI if EMI amount/day changed
                    final recurrings = await ref.read(recurringDaoProvider).getRecurring();
                    for (final r in recurrings) {
                      if (r.linkedLoanId == loan.id && r.isActive == 1) {
                        final now = DateTime.now();
                        final remainingMonths = tenure - paymentsMade;
                        final endMonth = now.month + remainingMonths;
                        final endDate = DateTime(now.year + (endMonth - 1) ~/ 12, (endMonth - 1) % 12 + 1, emiDay.clamp(1, 28));
                        final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

                        await ref.read(recurringDaoProvider).updateRecurring(
                          r.id,
                          name: '$name EMI',
                          amount: emiAmountPaise,
                          dayOfMonth: emiDay,
                          endDate: endDateStr,
                        );
                      }
                    }

                    ref.invalidate(loansProvider);
                    ref.invalidate(dashboardProvider);
                    ref.invalidate(recurringProvider);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(AppStrings.get('save_changes')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: valueColor)),
        ],
      ),
    );
  }
}
