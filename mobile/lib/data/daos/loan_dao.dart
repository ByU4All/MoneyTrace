import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class LoanDao {
  final AppDatabase _db;
  const LoanDao(this._db);

  static const _uuid = Uuid();

  Future<String> createLoan({
    required String name,
    required String type,
    required int principal,
    required double interestRate,
    required int tenureMonths,
    required int emiAmount,
    required String startDate,
    required int emiDay,
    String? paymentAccountId,
    String paymentType = 'manual',
    String? creditCardId,
    String? lender,
    String? purpose,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String().split('T')[0];

    await _db.into(_db.loans).insert(LoansCompanion.insert(
      id: id,
      name: name,
      type: type,
      principal: principal,
      interestRate: interestRate,
      tenureMonths: tenureMonths,
      emiAmount: emiAmount,
      startDate: startDate,
      emiDay: emiDay,
      paymentAccountId: Value(paymentAccountId),
      paymentType: Value(paymentType),
      creditCardId: Value(creditCardId),
      lender: Value(lender),
      purpose: Value(purpose),
      createdAt: now,
    ));

    return id;
  }

  Future<List<Loan>> getLoans({bool activeOnly = true}) async {
    final query = _db.select(_db.loans);
    if (activeOnly) {
      query.where((l) => l.isActive.equals(1));
    }
    query.orderBy([(l) => OrderingTerm.desc(l.createdAt)]);
    return query.get();
  }

  Future<Loan?> getLoan(String id) async {
    return (_db.select(_db.loans)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateLoan(String id, {
    String? name,
    int? emiAmount,
    int? emiDay,
    String? paymentAccountId,
    String? paymentType,
    String? lender,
    String? purpose,
    bool? isActive,
  }) async {
    final companion = LoansCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      emiAmount: emiAmount != null ? Value(emiAmount) : const Value.absent(),
      emiDay: emiDay != null ? Value(emiDay) : const Value.absent(),
      paymentAccountId: paymentAccountId != null ? Value(paymentAccountId) : const Value.absent(),
      paymentType: paymentType != null ? Value(paymentType) : const Value.absent(),
      lender: lender != null ? Value(lender) : const Value.absent(),
      purpose: purpose != null ? Value(purpose) : const Value.absent(),
      isActive: isActive != null ? Value(isActive ? 1 : 0) : const Value.absent(),
    );

    final count = await (_db.update(_db.loans)
          ..where((l) => l.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  Future<void> incrementPayment(String id) async {
    await _db.customStatement(
      'UPDATE loans SET payments_made = payments_made + 1 WHERE id = ?',
      [id],
    );

    // Auto-close if fully paid
    final loan = await getLoan(id);
    if (loan != null && loan.paymentsMade >= loan.tenureMonths) {
      await updateLoan(id, isActive: false);
    }
  }

  Future<bool> closeLoan(String id) async {
    return updateLoan(id, isActive: false);
  }

  // EMI Schedule methods

  Future<void> setEmiSchedule(String loanId, List<Map<String, int>> schedule) async {
    await (_db.delete(_db.loanEmiSchedule)
          ..where((s) => s.loanId.equals(loanId)))
        .go();

    final now = DateTime.now().toIso8601String().split('T')[0];
    for (final entry in schedule) {
      await _db.into(_db.loanEmiSchedule).insert(
        LoanEmiScheduleCompanion.insert(
          id: _uuid.v4(),
          loanId: loanId,
          monthNumber: entry['month_number']!,
          emiAmount: entry['emi_amount']!,
          createdAt: now,
        ),
      );
    }
  }

  Future<List<LoanEmiScheduleData>> getEmiSchedule(String loanId) async {
    return (_db.select(_db.loanEmiSchedule)
          ..where((s) => s.loanId.equals(loanId))
          ..orderBy([(s) => OrderingTerm.asc(s.monthNumber)]))
        .get();
  }

  Future<int> getEmiForMonth(String loanId, int monthNumber) async {
    final entry = await (_db.select(_db.loanEmiSchedule)
          ..where((s) => s.loanId.equals(loanId) & s.monthNumber.equals(monthNumber)))
        .getSingleOrNull();

    if (entry != null) return entry.emiAmount;

    final loan = await getLoan(loanId);
    return loan?.emiAmount ?? 0;
  }

  Future<void> deleteEmiSchedule(String loanId) async {
    await (_db.delete(_db.loanEmiSchedule)
          ..where((s) => s.loanId.equals(loanId)))
        .go();
  }
}
