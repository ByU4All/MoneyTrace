import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/recurring_processor.dart';
import 'l10n/strings.dart';
import 'services/notification_service.dart';
import 'providers/database_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/locale_provider.dart';
import 'theme/app_theme.dart';
import 'theme/colors.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/accounts_screen.dart' show AccountsScreen, addAccountTriggerProvider;
import 'screens/friends_screen.dart';
import 'screens/loans_screen.dart';
import 'screens/recurring_screen.dart';
import 'screens/credit_cards_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/visual_summary_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const ProviderScope(child: MoneyTraceApp()));
}

class MoneyTraceApp extends ConsumerWidget {
  const MoneyTraceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final largeText = ref.watch(largeTextProvider);

    return MaterialApp(
      title: 'MoneyTrace',
      theme: AppTheme.darkTheme(locale: locale),
      debugShowCheckedModeBanner: false,
      builder: largeText
          ? (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.15),
                ),
                child: child!,
              )
          : null,
      home: const AppStartup(),
      routes: {
        '/add': (context) => const AddEventScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/friends': (context) => const FriendsScreen(),
        '/loans': (context) => const LoansScreen(),
        '/credit-cards': (context) => const CreditCardsScreen(),
        '/history': (context) => const HistoryScreen(),
        '/recurring': (context) => const RecurringScreen(),
      },
    );
  }
}

/// Checks onboarding status on first launch and routes accordingly.
class AppStartup extends ConsumerStatefulWidget {
  const AppStartup({super.key});

  @override
  ConsumerState<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends ConsumerState<AppStartup> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final settingsDao = ref.read(settingsDaoProvider);
      final complete = await settingsDao.getOnboardingComplete().timeout(
        const Duration(seconds: 8),
        onTimeout: () => true,
      );
      if (mounted) setState(() => _onboardingComplete = complete);
    } catch (_) {
      // DB failure or timeout — skip onboarding and go straight to the app.
      if (mounted) setState(() => _onboardingComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('MoneyTrace', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
            ],
          ),
        ),
      );
    }
    if (_onboardingComplete!) return const MainShell();
    return OnboardingScreen(onComplete: () => setState(() => _onboardingComplete = true));
  }
}

/// Main navigation shell with bottom nav bar.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late final PageController _pageController;

  // 4-tab nav: Dashboard | History | Accounts | More (direct 1:1 mapping)
  static const _pages = [
    DashboardScreen(),
    HistoryScreen(),
    AccountsScreen(),
    _MoreScreen(),
  ];

  static const _widgetChannel = MethodChannel('com.luke.dev.moneytrace/widget');

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processAutopay();
      _handleWidgetAction();
      _checkCCNotifications();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(dashboardProvider);
      _checkCCNotifications();
    }
  }

  Future<void> _checkCCNotifications() async {
    try {
      await NotificationService.checkCreditCardDues(ref.read(creditCardDaoProvider));
    } catch (_) {
      // Notifications are best-effort — never crash the app
    }
  }

  Future<void> _handleWidgetAction() async {
    try {
      final action = await _widgetChannel.invokeMethod<String>('getWidgetAction');
      if (action == null || !mounted) return;

      switch (action) {
        case 'visual_summary':
          final data = await ref.read(dashboardProvider.future);
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => VisualSummaryScreen(data: data),
            ));
          }
        case 'liabilities':
          if (mounted) Navigator.pushNamed(context, '/friends');
        case 'receivables':
          if (mounted) Navigator.pushNamed(context, '/friends');
        case 'reserved':
          if (mounted) Navigator.pushNamed(context, '/recurring');
        // 'dashboard' or anything else → just open the app (already on dashboard)
      }
    } catch (_) {
      // No widget action — normal app launch
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _processAutopay() async {
    try {
      final processor = RecurringProcessor(
        ref.read(eventDaoProvider),
        ref.read(accountDaoProvider),
        ref.read(recurringDaoProvider),
      );
      await processor.processAutopay();
    } catch (_) {
      // Silently handle — autopay is best-effort on startup
    }
  }

  Widget? _buildFab() {
    switch (_currentIndex) {
      case 0: // Dashboard — Add Transaction (red)
        return FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/add'),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          tooltip: 'Add Transaction',
          child: const Icon(Icons.add),
        );
      case 2: // Accounts — Add Account (blue)
        return FloatingActionButton(
          onPressed: () => ref.read(addAccountTriggerProvider.notifier).state++,
          backgroundColor: AppColors.info,
          foregroundColor: Colors.white,
          tooltip: 'Add Account',
          child: const Icon(Icons.add),
        );
      default: // History (1) or More (3) — no FAB
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (pageIndex) {
          setState(() => _currentIndex = pageIndex);
        },
        children: _pages,
      ),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: AppStrings.get('nav_dashboard')),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: AppStrings.get('menu_history')),
          BottomNavigationBarItem(icon: const Icon(Icons.account_balance), label: AppStrings.get('nav_accounts')),
          BottomNavigationBarItem(icon: const Icon(Icons.more_horiz), label: AppStrings.get('nav_more')),
        ],
      ),
    );
  }
}

/// "More" screen with navigation links to other sections.
class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('nav_more'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuItem(context, Icons.people, AppStrings.get('menu_friends'), '/friends'),
          _menuItem(context, Icons.repeat, AppStrings.get('nav_recurring'), '/recurring'),
          _menuItem(context, Icons.receipt_long, AppStrings.get('menu_loans'), '/loans'),
          _menuItem(context, Icons.credit_card, AppStrings.get('menu_credit_cards'), '/credit-cards'),
          _menuItem(context, Icons.settings, AppStrings.get('menu_settings'), '/settings'),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, String route) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
