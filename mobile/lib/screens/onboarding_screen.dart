import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _budgetController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _newCategoryController = TextEditingController();
  String _accountType = 'bank';
  final List<String> _extraCategories = [];
  bool _completing = false;

  static const _defaultCategoryNames = [
    'Food & Dining', 'Transport', 'Shopping', 'Entertainment',
    'Bills & Utilities', 'Health', 'Travel', 'Salary', 'EMI',
    'Investment', 'Other',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _budgetController.dispose();
    _accountNameController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _next() => _goTo(_currentPage + 1);
  void _skip() => _goTo(4);

  Future<void> _complete() async {
    if (_completing) return;
    setState(() => _completing = true);
    try {
      final settingsDao = ref.read(settingsDaoProvider);
      final accountDao = ref.read(accountDaoProvider);
      final db = ref.read(databaseProvider);

      final budgetText = _budgetController.text.trim();
      if (budgetText.isNotEmpty) {
        final rupees = int.tryParse(budgetText);
        if (rupees != null && rupees > 0) {
          await settingsDao.setBaseBudget(rupees * 100);
        }
      }

      final accountName = _accountNameController.text.trim();
      if (accountName.isNotEmpty) {
        await accountDao.createAccount(name: accountName, type: _accountType);
      }

      const uuid = Uuid();
      for (final name in _extraCategories) {
        await db.into(db.categories).insert(CategoriesCompanion.insert(
          id: uuid.v4(),
          name: name,
        ));
      }

      await settingsDao.setOnboardingComplete(true);
      if (!mounted) return;
      widget.onComplete();
    } catch (_) {
      setState(() => _completing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _ProgressDots(current: _currentPage, total: 5),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _currentPage = p),
                children: [
                  _WelcomePage(textTheme: textTheme),
                  _BudgetPage(controller: _budgetController, textTheme: textTheme),
                  _AccountPage(
                    nameController: _accountNameController,
                    accountType: _accountType,
                    onTypeChanged: (t) => setState(() => _accountType = t),
                    textTheme: textTheme,
                  ),
                  _CategoriesPage(
                    extraCategories: _extraCategories,
                    newCategoryController: _newCategoryController,
                    onAddCategory: (name) => setState(() {
                      _extraCategories.add(name);
                      _newCategoryController.clear();
                    }),
                    defaultCategories: _defaultCategoryNames,
                    textTheme: textTheme,
                  ),
                  _DonePage(
                    budgetText: _budgetController.text,
                    accountName: _accountNameController.text,
                    extraCount: _extraCategories.length,
                    completing: _completing,
                    onComplete: _complete,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ),
            if (_currentPage < 4)
              _NavBar(
                currentPage: _currentPage,
                onBack: _currentPage > 0 ? () => _goTo(_currentPage - 1) : null,
                onSkip: _skip,
                onNext: _next,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress dots
// ---------------------------------------------------------------------------

class _ProgressDots extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.textMuted,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav bar (Back / Skip / Next)
// ---------------------------------------------------------------------------

class _NavBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback? onBack;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  const _NavBar({
    required this.currentPage,
    required this.onBack,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: onBack != null
                ? TextButton(
                    onPressed: onBack,
                    child: const Text('Back'),
                  )
                : null,
          ),
          const Spacer(),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text('Skip all'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared page wrapper
// ---------------------------------------------------------------------------

class _PageWrapper extends StatelessWidget {
  final Widget child;
  const _PageWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Page 0 — Welcome
// ---------------------------------------------------------------------------

class _WelcomePage extends StatelessWidget {
  final TextTheme textTheme;
  const _WelcomePage({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.account_balance_wallet, color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 28),
          Text('Welcome to\nMoneyTrace', style: textTheme.headlineLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            height: 1.2,
          )),
          const SizedBox(height: 12),
          Text('Your personal finance tracker — fully offline.', style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          )),
          const SizedBox(height: 36),
          ...[
            (Icons.track_changes, 'Track expenses, income, and transfers'),
            (Icons.bar_chart, 'Visualise your monthly budget'),
            (Icons.repeat, 'Manage recurring transactions'),
            (Icons.people_outline, 'Split bills with friends'),
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.$1, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(item.$2, style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  )),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
          Text("Let's get you set up in 2 minutes.", style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
          )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1 — Budget
// ---------------------------------------------------------------------------

class _BudgetPage extends StatelessWidget {
  final TextEditingController controller;
  final TextTheme textTheme;
  const _BudgetPage({required this.controller, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.savings_outlined, color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 28),
          Text('Monthly budget', style: textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 8),
          Text('How much do you plan to spend each month?', style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          )),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixText: '₹  ',
              prefixStyle: textTheme.headlineMedium?.copyWith(color: AppColors.textSecondary),
              hintText: '10000',
              hintStyle: textTheme.headlineMedium?.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
          const SizedBox(height: 16),
          Text('Default: ₹10,000  ·  You can change this anytime in Settings.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2 — Bank account
// ---------------------------------------------------------------------------

class _AccountPage extends StatelessWidget {
  final TextEditingController nameController;
  final String accountType;
  final ValueChanged<String> onTypeChanged;
  final TextTheme textTheme;
  const _AccountPage({
    required this.nameController,
    required this.accountType,
    required this.onTypeChanged,
    required this.textTheme,
  });

  static const _types = [
    ('cash', 'Cash'),
    ('bank', 'Bank'),
    ('upi', 'UPI'),
    ('other', 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.account_balance, color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 28),
          Text('Add an account', style: textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 8),
          Text('A Cash account is already ready to use. Add another account to track your bank or UPI balance.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Account name',
              hintText: 'e.g. HDFC Bank, Paytm UPI',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
          const SizedBox(height: 16),
          Text('Account type', style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _types.map((t) {
              final selected = accountType == t.$1;
              return ChoiceChip(
                label: Text(t.$2),
                selected: selected,
                onSelected: (_) => onTypeChanged(t.$1),
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Leave the name blank to skip this step.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 3 — Categories
// ---------------------------------------------------------------------------

class _CategoriesPage extends StatelessWidget {
  final List<String> extraCategories;
  final TextEditingController newCategoryController;
  final ValueChanged<String> onAddCategory;
  final List<String> defaultCategories;
  final TextTheme textTheme;
  const _CategoriesPage({
    required this.extraCategories,
    required this.newCategoryController,
    required this.onAddCategory,
    required this.defaultCategories,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.category_outlined, color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 28),
          Text('Starter categories', style: textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 8),
          Text('These are ready to use straight away. You can add more any time from Settings.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...defaultCategories.map((name) => _CategoryChip(name: name, isExtra: false)),
              ...extraCategories.map((name) => _CategoryChip(name: name, isExtra: true)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Add a custom category', style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: newCategoryController,
                  textCapitalization: TextCapitalization.words,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                  onSubmitted: (v) {
                    final name = v.trim();
                    if (name.isNotEmpty) onAddCategory(name);
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g. Gym, Fuel, Books',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  final name = newCategoryController.text.trim();
                  if (name.isNotEmpty) onAddCategory(name);
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final bool isExtra;
  const _CategoryChip({required this.name, required this.isExtra});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isExtra ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExtra ? AppColors.accent.withValues(alpha: 0.4) : AppColors.textMuted.withValues(alpha: 0.3),
        ),
      ),
      child: Text(name, style: TextStyle(
        color: isExtra ? AppColors.accentLight : AppColors.textSecondary,
        fontSize: 13,
      )),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 4 — Done
// ---------------------------------------------------------------------------

class _DonePage extends StatelessWidget {
  final String budgetText;
  final String accountName;
  final int extraCount;
  final bool completing;
  final VoidCallback onComplete;
  final TextTheme textTheme;
  const _DonePage({
    required this.budgetText,
    required this.accountName,
    required this.extraCount,
    required this.completing,
    required this.onComplete,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final budgetDisplay = budgetText.isNotEmpty
        ? '₹${_fmt(int.tryParse(budgetText) ?? 0)}/month'
        : '₹10,000/month (default)';
    final accountDisplay = accountName.isNotEmpty ? 'Cash + $accountName' : 'Cash';
    final catDisplay = '11 defaults${extraCount > 0 ? ' + $extraCount custom' : ''}';

    return _PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 44),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text("You're all set!", style: textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            )),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Here\'s what we set up:', style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            )),
          ),
          const SizedBox(height: 32),
          _SummaryRow(icon: Icons.savings_outlined, label: 'Monthly budget', value: budgetDisplay),
          const SizedBox(height: 12),
          _SummaryRow(icon: Icons.account_balance, label: 'Accounts', value: accountDisplay),
          const SizedBox(height: 12),
          _SummaryRow(icon: Icons.category_outlined, label: 'Categories', value: catDisplay),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: completing ? null : onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: completing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(completing ? 'Setting up…' : 'Start Tracking',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(n % 100000 == 0 ? 0 : 1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    return n.toString();
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
