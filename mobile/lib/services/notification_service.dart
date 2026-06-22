import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/daos/credit_card_dao.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _ccChannel = AndroidNotificationChannel(
    'cc_due',
    'Credit Card Payments',
    description: 'Reminders for upcoming credit card bill due dates',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    if (_initialized || !Platform.isAndroid) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: androidSettings));
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_ccChannel);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  static Future<void> checkCreditCardDues(CreditCardDao creditCardDao) async {
    if (!Platform.isAndroid) return;
    final statements = await creditCardDao.getStatements(unpaidOnly: true);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    for (final stmt in statements) {
      try {
        final dueDate = DateTime.parse(stmt.dueDate);
        final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
        final daysLeft = dueDateOnly.difference(todayOnly).inDays;

        if (daysLeft < 0 || daysLeft > 3) continue;

        final String title;
        if (daysLeft == 0) {
          title = 'Credit Card Payment Due Today';
        } else {
          title = 'Credit Card Due in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}';
        }

        final amountRupees = (stmt.statementAmount / 100).toStringAsFixed(0);
        final notifId = stmt.id.hashCode.abs() & 0x7FFFFFFF;

        await _plugin.show(
          notifId,
          title,
          '₹$amountRupees payment due — tap to open MoneyTrace',
          NotificationDetails(
            android: AndroidNotificationDetails(
              _ccChannel.id,
              _ccChannel.name,
              channelDescription: _ccChannel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      } catch (_) {
        // Skip statements with malformed date strings
      }
    }
  }
}
