/// Localization strings for MoneyTrace.
/// Supports English ('en') and Hindi ('hi').
class AppStrings {
  AppStrings._();

  static String _locale = 'en';

  static String get locale => _locale;

  static void setLocale(String locale) {
    _locale = locale;
  }

  /// Get a translated string by key.
  static String get(String key) {
    return _strings[key]?[_locale] ?? _strings[key]?['en'] ?? key;
  }

  /// Get a translated string with parameter substitution.
  /// Use {0}, {1}, etc. as placeholders.
  static String format(String key, List<String> params) {
    var result = get(key);
    for (var i = 0; i < params.length; i++) {
      result = result.replaceAll('{$i}', params[i]);
    }
    return result;
  }

  /// Display name for event types.
  static String eventTypeName(String type) {
    final key = 'event_type_$type';
    final val = _strings[key]?[_locale] ?? _strings[key]?['en'];
    return val ?? type;
  }

  /// Display name for account types.
  static String accountTypeName(String type) {
    final key = 'account_type_$type';
    final val = _strings[key]?[_locale] ?? _strings[key]?['en'];
    return val ?? type;
  }

  /// Display name for loan types.
  static String loanTypeName(String type) {
    final key = 'loan_type_$type';
    final val = _strings[key]?[_locale] ?? _strings[key]?['en'];
    return val ?? type;
  }

  /// Display name for recurring frequencies.
  static String frequencyName(String frequency) {
    final key = 'frequency_$frequency';
    final val = _strings[key]?[_locale] ?? _strings[key]?['en'];
    return val ?? frequency;
  }

  static const Map<String, Map<String, String>> _strings = {
    // ── Navigation ──
    'nav_dashboard': {'en': 'Dashboard', 'hi': 'डैशबोर्ड'},
    'nav_accounts': {'en': 'Accounts', 'hi': 'खाते'},
    'nav_add': {'en': 'Add', 'hi': 'जोड़ें'},
    'nav_recurring': {'en': 'Recurring', 'hi': 'आवर्ती'},
    'nav_more': {'en': 'More', 'hi': 'और'},

    // ── More menu ──
    'menu_friends': {'en': 'Friends', 'hi': 'दोस्त'},
    'menu_loans': {'en': 'Loans', 'hi': 'लोन'},
    'menu_credit_cards': {'en': 'Credit Cards', 'hi': 'क्रेडिट कार्ड'},
    'menu_history': {'en': 'History', 'hi': 'इतिहास'},
    'menu_settings': {'en': 'Settings', 'hi': 'सेटिंग्स'},

    // ── Budget Card ──
    'budget': {'en': 'Budget', 'hi': 'बजट'},
    'of_remaining': {'en': 'of {0} remaining', 'hi': '{0} में से शेष'},
    'spent': {'en': 'Spent', 'hi': 'खर्च'},
    'reserved': {'en': 'Reserved', 'hi': 'आरक्षित'},
    'you_owe': {'en': 'You Owe', 'hi': 'आप पर उधार'},
    'owed_to_you': {'en': 'Owed to You', 'hi': 'आपको मिलना'},

    // ── Dashboard ──
    'spending_by_category': {'en': 'Spending by Category', 'hi': 'श्रेणी अनुसार खर्च'},
    'recent_activity': {'en': 'Recent Activity', 'hi': 'हाल की गतिविधि'},
    'view_all': {'en': 'View All', 'hi': 'सब देखें'},
    'no_transactions_yet': {'en': 'No transactions yet', 'hi': 'कोई लेन-देन नहीं'},
    'unpaid_recurring_this_month': {'en': 'Unpaid recurring this month', 'hi': 'इस महीने बकाया आवर्ती'},
    'no_balances': {'en': 'No balances', 'hi': 'कोई बकाया नहीं'},

    // ── Event type names ──
    'event_type_expense': {'en': 'Expense', 'hi': 'खर्च'},
    'event_type_liability': {'en': 'I Owe', 'hi': 'मैंने उधार लिया'},
    'event_type_receivable': {'en': 'Owes Me', 'hi': 'मुझे देना है'},
    'event_type_settlement_paid': {'en': 'Settled (Paid)', 'hi': 'चुकता (भुगतान)'},
    'event_type_settlement_received': {'en': 'Settled (Received)', 'hi': 'चुकता (प्राप्त)'},
    'event_type_budget_adjustment': {'en': 'Adjustment', 'hi': 'समायोजन'},
    'event_type_transfer': {'en': 'Transfer', 'hi': 'ट्रांसफ़र'},
    'event_type_income': {'en': 'Income', 'hi': 'आय'},
    'event_type_credit_card_payment': {'en': 'CC Payment', 'hi': 'CC भुगतान'},
    'event_type_emi_payment': {'en': 'EMI Payment', 'hi': 'EMI भुगतान'},

    // ── Account type names ──
    'account_type_savings': {'en': 'Savings', 'hi': 'बचत'},
    'account_type_current': {'en': 'Current', 'hi': 'चालू'},
    'account_type_cash': {'en': 'Cash', 'hi': 'नकद'},
    'account_type_credit_card': {'en': 'Credit Card', 'hi': 'क्रेडिट कार्ड'},
    'account_type_upi_wallet': {'en': 'UPI Wallet', 'hi': 'UPI वॉलेट'},
    'account_type_debit_card': {'en': 'Debit Card', 'hi': 'डेबिट कार्ड'},

    // ── Loan type names ──
    'loan_type_home_loan': {'en': 'Home Loan', 'hi': 'होम लोन'},
    'loan_type_car_loan': {'en': 'Car Loan', 'hi': 'कार लोन'},
    'loan_type_personal_loan': {'en': 'Personal Loan', 'hi': 'पर्सनल लोन'},
    'loan_type_credit_card_emi': {'en': 'Credit Card EMI', 'hi': 'क्रेडिट कार्ड EMI'},
    'loan_type_bnpl': {'en': 'Buy Now Pay Later', 'hi': 'अभी खरीदो बाद में भुगतान'},
    'loan_type_other': {'en': 'Other', 'hi': 'अन्य'},

    // ── Frequency names ──
    'frequency_daily': {'en': 'Daily', 'hi': 'दैनिक'},
    'frequency_weekly': {'en': 'Weekly', 'hi': 'साप्ताहिक'},
    'frequency_monthly': {'en': 'Monthly', 'hi': 'मासिक'},
    'frequency_bimonthly': {'en': 'Every 2 Months', 'hi': 'हर 2 महीने'},
    'frequency_quarterly': {'en': 'Quarterly', 'hi': 'तिमाही'},
    'frequency_half_yearly': {'en': 'Half Yearly', 'hi': 'छमाही'},
    'frequency_yearly': {'en': 'Yearly', 'hi': 'वार्षिक'},

    // ── Accounts Screen ──
    'accounts': {'en': 'Accounts', 'hi': 'खाते'},
    'add_account': {'en': 'Add Account', 'hi': 'खाता जोड़ें'},
    'no_accounts_yet': {'en': 'No accounts yet', 'hi': 'कोई खाता नहीं'},
    'account_name': {'en': 'Account Name', 'hi': 'खाते का नाम'},
    'type': {'en': 'Type', 'hi': 'प्रकार'},
    'institution_optional': {'en': 'Institution (optional)', 'hi': 'संस्था (वैकल्पिक)'},
    'initial_balance': {'en': 'Initial Balance (\u20B9)', 'hi': 'प्रारंभिक शेष (\u20B9)'},
    'credit_limit': {'en': 'Credit Limit (\u20B9)', 'hi': 'क्रेडिट लिमिट (\u20B9)'},
    'billing_day': {'en': 'Billing Day', 'hi': 'बिलिंग दिन'},
    'due_day': {'en': 'Due Day', 'hi': 'देय दिन'},
    'edit_account': {'en': 'Edit Account', 'hi': 'खाता संपादित करें'},
    'save_changes': {'en': 'Save Changes', 'hi': 'बदलाव सहेजें'},
    'balance': {'en': 'Balance', 'hi': 'शेष'},
    'edit': {'en': 'Edit', 'hi': 'संपादित करें'},
    'deactivate': {'en': 'Deactivate', 'hi': 'निष्क्रिय करें'},

    // ── Add Event Screen ──
    'add_transaction': {'en': 'Add Transaction', 'hi': 'लेन-देन जोड़ें'},
    'tab_expense': {'en': 'Expense', 'hi': 'खर्च'},
    'tab_income': {'en': 'Income', 'hi': 'आय'},
    'tab_transfer': {'en': 'Transfer', 'hi': 'ट्रांसफ़र'},
    'tab_i_owe': {'en': 'I Owe', 'hi': 'उधार लिया'},
    'tab_owes_me': {'en': 'Owes Me', 'hi': 'देना है'},
    'tab_settle': {'en': 'Settle', 'hi': 'चुकता'},
    'i_paid': {'en': 'I Paid', 'hi': 'मैंने दिया'},
    'i_received': {'en': 'I Received', 'hi': 'मुझे मिला'},
    'amount': {'en': 'Amount (\u20B9)', 'hi': 'राशि (\u20B9)'},
    'description_optional': {'en': 'Description (optional)', 'hi': 'विवरण (वैकल्पिक)'},
    'category': {'en': 'Category', 'hi': 'श्रेणी'},
    'friend': {'en': 'Friend', 'hi': 'दोस्त'},
    'from_account': {'en': 'From Account', 'hi': 'किस खाते से'},
    'to_account': {'en': 'To Account', 'hi': 'किस खाते में'},
    'account_required': {'en': 'Account (required)', 'hi': 'खाता (आवश्यक)'},
    'account_optional': {'en': 'Account (optional)', 'hi': 'खाता (वैकल्पिक)'},
    'no_account': {'en': 'No account', 'hi': 'कोई खाता नहीं'},
    'date': {'en': 'Date', 'hi': 'तारीख'},
    'complete_a_recurring': {'en': 'Complete a Recurring?', 'hi': 'आवर्ती पूरा करें?'},
    'no_pending_recurring': {'en': 'No pending recurring transactions', 'hi': 'कोई बकाया आवर्ती लेन-देन नहीं'},
    'select_recurring': {'en': 'Select Recurring', 'hi': 'आवर्ती चुनें'},
    'please_enter_amount': {'en': 'Please enter an amount', 'hi': 'कृपया राशि दर्ज करें'},
    'invalid_amount': {'en': 'Invalid amount', 'hi': 'अमान्य राशि'},
    'please_select_account': {'en': 'Please select an account', 'hi': 'कृपया खाता चुनें'},
    'please_select_both_accounts': {'en': 'Please select both From and To accounts', 'hi': 'कृपया दोनों खाते चुनें'},
    'transaction_added': {'en': 'Transaction added!', 'hi': 'लेन-देन जोड़ा गया!'},

    // ── Edit Event Screen ──
    'edit_transaction': {'en': 'Edit Transaction', 'hi': 'लेन-देन संपादित करें'},
    'account': {'en': 'Account', 'hi': 'खाता'},
    'save_changes_q': {'en': 'Save Changes?', 'hi': 'बदलाव सहेजें?'},
    'save_changes_msg': {'en': 'This will update the transaction and adjust account balances.', 'hi': 'इससे लेन-देन अपडेट होगा और खाता शेष समायोजित होगा।'},
    'save': {'en': 'Save', 'hi': 'सहेजें'},
    'transaction_updated': {'en': 'Transaction updated!', 'hi': 'लेन-देन अपडेट हुआ!'},

    // ── Recurring Screen ──
    'recurring': {'en': 'Recurring', 'hi': 'आवर्ती'},
    'add_recurring': {'en': 'Add Recurring', 'hi': 'आवर्ती जोड़ें'},
    'pending_verification': {'en': 'Pending Verification', 'hi': 'सत्यापन बाकी'},
    'no_recurring_transactions': {'en': 'No recurring transactions', 'hi': 'कोई आवर्ती लेन-देन नहीं'},
    'active': {'en': 'Active', 'hi': 'सक्रिय'},
    'add_recurring_transaction': {'en': 'Add Recurring Transaction', 'hi': 'आवर्ती लेन-देन जोड़ें'},
    'name': {'en': 'Name', 'hi': 'नाम'},
    'emi': {'en': 'EMI', 'hi': 'EMI'},
    'frequency': {'en': 'Frequency', 'hi': 'अवधि'},
    'day_of_month': {'en': 'Day of Month', 'hi': 'महीने का दिन'},
    'autopay': {'en': 'Autopay', 'hi': 'ऑटोपे'},
    'autopay_subtitle': {'en': 'Auto-create transactions on due date', 'hi': 'देय तिथि पर स्वचालित लेन-देन बनाएं'},
    'add': {'en': 'Add', 'hi': 'जोड़ें'},
    'edit_recurring_transaction': {'en': 'Edit Recurring Transaction', 'hi': 'आवर्ती लेन-देन संपादित करें'},
    'none': {'en': 'None', 'hi': 'कोई नहीं'},
    'delete': {'en': 'Delete', 'hi': 'हटाएं'},

    // ── Loans Screen ──
    'loans': {'en': 'Loans', 'hi': 'लोन'},
    'add_loan': {'en': 'Add Loan', 'hi': 'लोन जोड़ें'},
    'no_active_loans': {'en': 'No active loans', 'hi': 'कोई सक्रिय लोन नहीं'},
    'emis_remaining': {'en': '{0} EMIs remaining', 'hi': '{0} EMI बाकी'},
    'of_emis_remaining': {'en': '{0} of {1} EMIs remaining', 'hi': '{1} में से {0} EMI बाकी'},
    'outstanding': {'en': 'Outstanding', 'hi': 'बकाया'},
    'loan_name': {'en': 'Loan Name', 'hi': 'लोन का नाम'},
    'principal': {'en': 'Principal', 'hi': 'मूलधन'},
    'principal_amount': {'en': 'Principal (\u20B9)', 'hi': 'मूलधन (\u20B9)'},
    'interest_pct': {'en': 'Interest (%/yr)', 'hi': 'ब्याज (%/वर्ष)'},
    'interest_rate': {'en': 'Interest Rate', 'hi': 'ब्याज दर'},
    'tenure_months': {'en': 'Tenure (months)', 'hi': 'अवधि (महीने)'},
    'emi_amount': {'en': 'EMI (\u20B9)', 'hi': 'EMI (\u20B9)'},
    'emi_day': {'en': 'EMI Day', 'hi': 'EMI दिन'},
    'lender_optional': {'en': 'Lender (optional)', 'hi': 'ऋणदाता (वैकल्पिक)'},
    'loan_start_date': {'en': 'Loan Start Date', 'hi': 'लोन शुरू तिथि'},
    'emis_already_paid': {'en': 'EMIs Already Paid', 'hi': 'चुकाई गई EMI'},
    'please_fill_required': {'en': 'Please fill all required fields', 'hi': 'कृपया सभी आवश्यक फ़ील्ड भरें'},
    'emis_paid_less_tenure': {'en': 'EMIs paid must be less than tenure', 'hi': 'चुकाई गई EMI अवधि से कम होनी चाहिए'},
    'total_paid': {'en': 'Total Paid', 'hi': 'कुल भुगतान'},
    'lender': {'en': 'Lender', 'hi': 'ऋणदाता'},
    'edit_loan': {'en': 'Edit Loan', 'hi': 'लोन संपादित करें'},
    'close_loan_q': {'en': 'Close Loan?', 'hi': 'लोन बंद करें?'},
    'mark_loan_inactive': {'en': 'Mark this loan as inactive?', 'hi': 'इस लोन को निष्क्रिय करें?'},
    'cancel': {'en': 'Cancel', 'hi': 'रद्द करें'},
    'close': {'en': 'Close', 'hi': 'बंद करें'},
    'close_loan': {'en': 'Close Loan', 'hi': 'लोन बंद करें'},

    // ── Friends Screen ──
    'friends': {'en': 'Friends', 'hi': 'दोस्त'},
    'no_friends_yet': {'en': 'No friends added yet', 'hi': 'कोई दोस्त नहीं जोड़ा'},
    'owes_you': {'en': 'Owes you {0}', 'hi': '{0} देना है'},
    'you_owe_amount': {'en': 'You owe {0}', 'hi': 'आप पर {0} उधार'},
    'settled_up': {'en': 'Settled up', 'hi': 'चुकता'},
    'unknown': {'en': 'Unknown', 'hi': 'अज्ञात'},
    'add_friend': {'en': 'Add Friend', 'hi': 'दोस्त जोड़ें'},
    'phone_optional': {'en': 'Phone (optional)', 'hi': 'फ़ोन (वैकल्पिक)'},
    'owes_you_label': {'en': 'Owes you', 'hi': 'देना है'},
    'you_owe_label': {'en': 'You owe', 'hi': 'आप पर उधार'},
    'delete_friend_q': {'en': 'Delete Friend?', 'hi': 'दोस्त हटाएं?'},
    'remove_name': {'en': 'Remove "{0}"?', 'hi': '"{0}" को हटाएं?'},

    // ── Credit Cards Screen ──
    'credit_cards': {'en': 'Credit Cards', 'hi': 'क्रेडिट कार्ड'},
    'no_credit_cards': {'en': 'No credit cards', 'hi': 'कोई क्रेडिट कार्ड नहीं'},
    'available': {'en': 'Available', 'hi': 'उपलब्ध'},
    'limit': {'en': 'Limit', 'hi': 'सीमा'},
    'edit_card_name': {'en': 'Edit {0}', 'hi': '{0} संपादित करें'},
    'paid': {'en': 'Paid', 'hi': 'भुगतान किया'},
    'unpaid': {'en': 'Unpaid', 'hi': 'बकाया'},
    'no_statements': {'en': 'No statements', 'hi': 'कोई स्टेटमेंट नहीं'},
    'edit_card': {'en': 'Edit Card', 'hi': 'कार्ड संपादित करें'},
    'statement_date': {'en': 'Statement: {0}', 'hi': 'स्टेटमेंट: {0}'},
    'due_paid_status': {'en': 'Due: {0}', 'hi': 'देय: {0}'},

    // ── History Screen ──
    'history': {'en': 'History', 'hi': 'इतिहास'},
    'money_only': {'en': 'Money Only', 'hi': 'केवल पैसा'},
    'all_activity': {'en': 'All Activity', 'hi': 'सभी गतिविधि'},
    'delete_transaction_q': {'en': 'Delete Transaction?', 'hi': 'लेन-देन हटाएं?'},
    'delete_transaction_msg': {'en': 'Delete {0} for {1}?', 'hi': '{1} का {0} हटाएं?'},

    // ── Visual Summary Screen ──
    'budget_summary': {'en': 'Budget Summary', 'hi': 'बजट सारांश'},
    'overview': {'en': 'Overview', 'hi': 'अवलोकन'},
    'total_spent': {'en': 'Total Spent', 'hi': 'कुल खर्च'},

    // ── Settings Screen ──
    'settings': {'en': 'Settings', 'hi': 'सेटिंग्स'},
    'general': {'en': 'General', 'hi': 'सामान्य'},
    'categories': {'en': 'Categories', 'hi': 'श्रेणियां'},
    'data': {'en': 'Data', 'hi': 'डेटा'},
    'display': {'en': 'Display', 'hi': 'प्रदर्शन'},
    'language': {'en': 'Language', 'hi': 'भाषा'},
    'larger_text': {'en': 'Larger Text', 'hi': 'बड़ा टेक्स्ट'},
    'budget_settings': {'en': 'Budget Settings', 'hi': 'बजट सेटिंग्स'},
    'monthly_budget': {'en': 'Monthly Budget (\u20B9)', 'hi': 'मासिक बजट (\u20B9)'},
    'reset_day': {'en': 'Reset Day (1-28)', 'hi': 'रीसेट दिन (1-28)'},
    'carry_over_balance': {'en': 'Carry Over Balance', 'hi': 'शेष आगे ले जाएं'},
    'carry_over_subtitle': {'en': 'Carry unused budget to next month', 'hi': 'बचा हुआ बजट अगले महीने में ले जाएं'},
    'carry_over_cap': {'en': 'Carry Over Cap (\u20B9, 0 = unlimited)', 'hi': 'कैरी ओवर सीमा (\u20B9, 0 = असीमित)'},
    'carry_negative': {'en': 'Carry Negative Balance', 'hi': 'ऋणात्मक शेष आगे ले जाएं'},
    'save_settings': {'en': 'Save Settings', 'hi': 'सेटिंग्स सहेजें'},
    'invalid_values': {'en': 'Invalid values', 'hi': 'अमान्य मान'},
    'settings_saved': {'en': 'Settings saved!', 'hi': 'सेटिंग्स सहेजी गई!'},
    'new_category_name': {'en': 'New category name', 'hi': 'नई श्रेणी का नाम'},
    'default_label': {'en': 'Default', 'hi': 'डिफ़ॉल्ट'},
    'backup': {'en': 'Backup', 'hi': 'बैकअप'},
    'export_data': {'en': 'Export Data', 'hi': 'डेटा निर्यात'},
    'export_data_subtitle': {'en': 'Save JSON backup to Downloads/MoneyTrace', 'hi': 'Downloads/MoneyTrace में JSON बैकअप सहेजें'},
    'restore': {'en': 'Restore', 'hi': 'पुनर्स्थापित'},
    'import_data': {'en': 'Import Data', 'hi': 'डेटा आयात'},
    'import_data_subtitle': {'en': 'Restore from a JSON backup file (replaces all data)', 'hi': 'JSON बैकअप से पुनर्स्थापित करें (सभी डेटा बदल जाएगा)'},
    'danger_zone': {'en': 'Danger Zone', 'hi': 'खतरनाक क्षेत्र'},
    'clear_all_data': {'en': 'Clear All Data', 'hi': 'सभी डेटा हटाएं'},
    'clear_data_subtitle': {'en': 'Delete all data and reset to defaults', 'hi': 'सभी डेटा हटाएं और डिफ़ॉल्ट पर रीसेट करें'},
    'backup_saved': {'en': 'Backup saved to {0}', 'hi': '{0} में बैकअप सहेजा'},
    'export_failed': {'en': 'Export failed: {0}', 'hi': 'निर्यात विफल: {0}'},
    'import_backup': {'en': 'Import Backup', 'hi': 'बैकअप आयात'},
    'no_backups_found': {'en': 'No backups found', 'hi': 'कोई बैकअप नहीं मिला'},
    'browse_other_files': {'en': 'Browse other files...', 'hi': 'अन्य फ़ाइलें खोजें...'},
    'could_not_read_file': {'en': 'Could not read file', 'hi': 'फ़ाइल पढ़ नहीं सकी'},
    'import_data_q': {'en': 'Import Data?', 'hi': 'डेटा आयात करें?'},
    'import_data_warning': {'en': 'This will replace ALL existing data with the backup. This cannot be undone.', 'hi': 'यह सभी मौजूदा डेटा को बैकअप से बदल देगा। यह पूर्ववत नहीं किया जा सकता।'},
    'import': {'en': 'Import', 'hi': 'आयात'},
    'data_imported': {'en': 'Data imported successfully!', 'hi': 'डेटा सफलतापूर्वक आयात हुआ!'},
    'import_failed': {'en': 'Import failed: {0}', 'hi': 'आयात विफल: {0}'},
    'clear_all_data_q': {'en': 'Clear All Data?', 'hi': 'सभी डेटा हटाएं?'},
    'clear_data_warning': {'en': 'This will permanently delete all transactions and month records. Settings and categories will be kept.', 'hi': 'यह सभी लेन-देन और माह रिकॉर्ड स्थायी रूप से हटा देगा। सेटिंग्स और श्रेणियां रहेंगी।'},
    'clear': {'en': 'Clear', 'hi': 'हटाएं'},
    'all_data_cleared': {'en': 'All data cleared!', 'hi': 'सभी डेटा हटाया गया!'},
    'error': {'en': 'Error: {0}', 'hi': 'त्रुटि: {0}'},

    // ── Feedback batch additions (4 March 2026) ──
    'next_emi_in': {'en': 'Next EMI in', 'hi': 'अगली EMI'},
    'days': {'en': '{0} days', 'hi': '{0} दिन'},
    'today': {'en': 'today', 'hi': 'आज'},
    'on_hold': {'en': 'On Hold', 'hi': 'होल्ड पर'},
    'on_hold_subtitle': {'en': 'Reserved for upcoming auto-pay', 'hi': 'आगामी ऑटो-पे के लिए आरक्षित'},
    'autopay_reason': {'en': 'Auto-pay: {0}', 'hi': 'ऑटो-पे: {0}'},
    'all_done_this_month': {'en': 'All done for this month ✓', 'hi': 'इस महीने सब हो गया ✓'},
    'due_this_month': {'en': 'Due This Month', 'hi': 'इस महीने देय'},
    'paid_this_month': {'en': 'Paid This Month', 'hi': 'इस महीने भुगतान'},
    'upcoming': {'en': 'Upcoming', 'hi': 'आगामी'},
    'mark_paid': {'en': 'Mark Paid', 'hi': 'भुगतान चिह्नित'},
    'initial_balance_warning': {
      'en': 'Editing this overwrites the balance directly. To record an actual transaction, use Adjust instead.',
      'hi': 'इसे संपादित करने से शेष राशि सीधे बदल जाती है। वास्तविक लेन-देन के लिए समायोजन का उपयोग करें।'
    },
    'large_change_warning': {
      'en': 'New balance differs by more than 10%. Confirm?',
      'hi': 'नई शेष राशि 10% से अधिक भिन्न है। पुष्टि करें?'
    },
    'with_friends_optional': {'en': 'With friends (optional)', 'hi': 'दोस्तों के साथ (वैकल्पिक)'},
    'no_friends_to_tag': {'en': 'Add a friend first to tag them.', 'hi': 'टैग करने के लिए पहले दोस्त जोड़ें।'},
    'friend_history': {'en': 'History with {0}', 'hi': '{0} के साथ इतिहास'},
    'no_history_with_friend': {'en': 'No transactions with this friend yet', 'hi': 'इस दोस्त के साथ कोई लेन-देन नहीं'},
    'running_balance': {'en': 'Running balance', 'hi': 'चालू शेष'},
    'delete_friend_with_count': {
      'en': '{0} has {1} transaction(s) worth {2}.',
      'hi': '{0} के साथ {1} लेन-देन हैं, कुल {2}।'
    },
    'delete_friend_choose': {
      'en': 'What should happen to those transactions?',
      'hi': 'उन लेन-देन का क्या करें?'
    },
    'keep_unlink': {'en': 'Keep, unlink', 'hi': 'रखें, अनलिंक'},
    'delete_with_events': {'en': 'Delete with friend', 'hi': 'दोस्त के साथ हटाएं'},

};
}
