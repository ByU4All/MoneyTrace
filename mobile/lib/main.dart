import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/recurring_processor.dart';
import 'l10n/strings.dart';
import 'providers/database_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/locale_provider.dart';
import 'theme/app_theme.dart';
import 'theme/colors.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/loans_screen.dart';
import 'screens/recurring_screen.dart';
import 'screens/credit_cards_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/visual_summary_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MainShell(),
      routes: {
        '/add': (context) => const AddEventScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/friends': (context) => const FriendsScreen(),
        '/loans': (context) => const LoansScreen(),
        '/credit-cards': (context) => const CreditCardsScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
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

  // Actual page screens (no placeholder for index 2)
  static const _pages = [
    DashboardScreen(),  // nav index 0 → page 0
    AccountsScreen(),   // nav index 1 → page 1
    RecurringScreen(),  // nav index 3 → page 2
    _MoreScreen(),      // nav index 4 → page 3
  ];

  // Maps nav bar index → page index (skipping index 2 = Add)
  int _navToPage(int navIndex) {
    if (navIndex <= 1) return navIndex;
    return navIndex - 1; // 3→2, 4→3
  }

  // Maps page index → nav bar index
  int _pageToNav(int pageIndex) {
    if (pageIndex <= 1) return pageIndex;
    return pageIndex + 1; // 2→3, 3→4
  }

  static const _widgetChannel = MethodChannel('com.luke.dev.moneytrace/widget');

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processAutopay();
      _handleWidgetAction();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(dashboardProvider);
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
          // Navigate to recurring screen
          if (mounted) {
            setState(() => _currentIndex = 3); // recurring nav index
            _pageController.jumpToPage(2); // recurring page index
          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (pageIndex) {
          setState(() => _currentIndex = _pageToNav(pageIndex));
        },
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushNamed(context, '/add');
          } else {
            setState(() => _currentIndex = index);
            _pageController.jumpToPage(_navToPage(index));
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: AppStrings.get('nav_dashboard')),
          BottomNavigationBarItem(icon: const Icon(Icons.account_balance), label: AppStrings.get('nav_accounts')),
          BottomNavigationBarItem(icon: const Icon(Icons.add_circle_outline), label: AppStrings.get('nav_add')),
          BottomNavigationBarItem(icon: const Icon(Icons.repeat), label: AppStrings.get('nav_recurring')),
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
          _menuItem(context, Icons.receipt_long, AppStrings.get('menu_loans'), '/loans'),
          _menuItem(context, Icons.credit_card, AppStrings.get('menu_credit_cards'), '/credit-cards'),
          _menuItem(context, Icons.history, AppStrings.get('menu_history'), '/history'),
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
