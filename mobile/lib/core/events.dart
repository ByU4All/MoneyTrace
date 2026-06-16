/// Event types - the financial primitives.
///
/// This is the SINGLE source of truth for event types.
/// String values must match Python backend exactly.

enum EventType {
  expense('expense'),
  liability('liability'),
  receivable('receivable'),
  settlementPaid('settlement_paid'),
  settlementReceived('settlement_received'),
  budgetAdjustment('budget_adjustment'),
  transfer('transfer'),
  income('income'),
  creditCardPayment('credit_card_payment'),
  emiPayment('emi_payment');

  const EventType(this.value);
  final String value;

  static EventType fromString(String s) =>
      EventType.values.firstWhere((e) => e.value == s);
}

enum AccountType {
  savings('savings'),
  current('current'),
  cash('cash'),
  creditCard('credit_card'),
  upiWallet('upi_wallet'),
  debitCard('debit_card');

  const AccountType(this.value);
  final String value;

  static AccountType fromString(String s) =>
      AccountType.values.firstWhere((e) => e.value == s);
}

enum RecurringFrequency {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  bimonthly('bimonthly'),
  quarterly('quarterly'),
  halfYearly('half_yearly'),
  yearly('yearly');

  const RecurringFrequency(this.value);
  final String value;

  static RecurringFrequency fromString(String s) =>
      RecurringFrequency.values.firstWhere((e) => e.value == s);
}

enum LoanType {
  homeLoan('home_loan'),
  carLoan('car_loan'),
  personalLoan('personal_loan'),
  creditCardEmi('credit_card_emi'),
  bnpl('bnpl'),
  other('other');

  const LoanType(this.value);
  final String value;

  static LoanType fromString(String s) =>
      LoanType.values.firstWhere((e) => e.value == s);
}

enum AuditAction {
  create('create'),
  update('update'),
  delete('delete'),
  close('close'),
  unlink('unlink');

  const AuditAction(this.value);
  final String value;
}

enum EntityType {
  event('event'),
  friend('friend'),
  account('account'),
  loan('loan'),
  recurring('recurring'),
  category('category'),
  settings('settings');

  const EntityType(this.value);
  final String value;
}
