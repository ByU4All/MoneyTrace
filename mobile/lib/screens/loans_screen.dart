import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../providers/dashboard_provider.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import 'recurring_screen.dart' show recurringProvider;
import '../widgets/amount_display.dart';
import '../widgets/progress_bar.dart';

final loansProvider = FutureProvider.autoDispose<List<Loan>>((ref) async {
  return ref.watch(loanDaoProvider).getLoans();
});

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card),
            tooltip: 'Add Loan',
            onPressed: () => _showAddLoanSheet(context, ref),
          ),
        ],
      ),
      body: loansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (loans) {
          if (loans.isEmpty) {
            return const Center(
              child: Text('No active loans', style: TextStyle(color: AppColors.textMuted)),
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
                            Text('$remaining EMIs remaining', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
                                const Text('EMI', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                Text(formatAmount(loan.emiAmount), style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Outstanding', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                Text(formatAmount(outstanding), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
                              ],
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
                const Text('Add Loan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Loan Name')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'home_loan', child: Text('Home Loan')),
                    DropdownMenuItem(value: 'car_loan', child: Text('Car Loan')),
                    DropdownMenuItem(value: 'personal_loan', child: Text('Personal Loan')),
                    DropdownMenuItem(value: 'credit_card_emi', child: Text('Credit Card EMI')),
                    DropdownMenuItem(value: 'bnpl', child: Text('Buy Now Pay Later')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: principalCtrl, decoration: const InputDecoration(labelText: 'Principal (\u20B9)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'Interest (%/yr)'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: tenureCtrl, decoration: const InputDecoration(labelText: 'Tenure (months)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: emiCtrl, decoration: const InputDecoration(labelText: 'EMI (\u20B9)'), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: emiDayCtrl, decoration: const InputDecoration(labelText: 'EMI Day'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: lenderCtrl, decoration: const InputDecoration(labelText: 'Lender (optional)'))),
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
                    decoration: const InputDecoration(labelText: 'Loan Start Date'),
                    child: Text(
                      '${loanStartDate.year}-${loanStartDate.month.toString().padLeft(2, '0')}-${loanStartDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paymentsMadeCtrl,
                  decoration: const InputDecoration(labelText: 'EMIs Already Paid'),
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
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

                    if (paymentsMade >= tenure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('EMIs paid must be less than tenure')),
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
                  child: const Text('Add Loan'),
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
                  Text('${loan.tenureMonths - loan.paymentsMade} of ${loan.tenureMonths} EMIs remaining', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text('${progress.round()}%', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow('Principal', formatAmount(loan.principal)),
              _detailRow('Interest Rate', '${loan.interestRate}%'),
              _detailRow('EMI', formatAmount(loan.emiAmount)),
              _detailRow('Outstanding', formatAmount(outstanding), valueColor: AppColors.danger),
              _detailRow('Total Paid', formatAmount(totalPaid), valueColor: AppColors.success),
              _detailRow('EMI Day', '${loan.emiDay}th'),
              if (loan.lender != null) _detailRow('Lender', loan.lender!),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditLoanSheet(context, ref, loan);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Loan'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Close Loan?'),
                      content: const Text('Mark this loan as inactive?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                          child: const Text('Close'),
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
                label: const Text('Close Loan', style: TextStyle(color: AppColors.danger)),
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
                const Text('Edit Loan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Loan Name')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: principalCtrl, decoration: const InputDecoration(labelText: 'Principal (\u20B9)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'Interest (%/yr)'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: tenureCtrl, decoration: const InputDecoration(labelText: 'Tenure (months)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: emiCtrl, decoration: const InputDecoration(labelText: 'EMI (\u20B9)'), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: emiDayCtrl, decoration: const InputDecoration(labelText: 'EMI Day'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: lenderCtrl, decoration: const InputDecoration(labelText: 'Lender (optional)'))),
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
                    decoration: const InputDecoration(labelText: 'Loan Start Date'),
                    child: Text(
                      '${loanStartDate.year}-${loanStartDate.month.toString().padLeft(2, '0')}-${loanStartDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paymentsMadeCtrl,
                  decoration: const InputDecoration(labelText: 'EMIs Already Paid'),
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
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

                    if (paymentsMade >= tenure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('EMIs paid must be less than tenure')),
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
                  child: const Text('Save Changes'),
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
