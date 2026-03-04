import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/recurring_processor.dart';
import 'providers/database_provider.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MoneyTraceApp()));
}

class MoneyTraceApp extends StatelessWidget {
  const MoneyTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyTrace',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
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

class _MainShellState extends ConsumerState<MainShell> {
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Run autopay processing on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processAutopay();
    });
  }

  @override
  void dispose() {
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Accounts'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.repeat), label: 'Recurring'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
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
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuItem(context, Icons.people, 'Friends', '/friends'),
          _menuItem(context, Icons.receipt_long, 'Loans', '/loans'),
          _menuItem(context, Icons.credit_card, 'Credit Cards', '/credit-cards'),
          _menuItem(context, Icons.history, 'History', '/history'),
          _menuItem(context, Icons.settings, 'Settings', '/settings'),
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
