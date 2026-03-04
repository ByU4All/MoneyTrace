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

  @override
  void initState() {
    super.initState();
    // Run autopay processing on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processAutopay();
    });
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

  final _screens = const [
    DashboardScreen(),
    AccountsScreen(),
    SizedBox(), // Placeholder for FAB
    RecurringScreen(),
    _MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _screens,
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
