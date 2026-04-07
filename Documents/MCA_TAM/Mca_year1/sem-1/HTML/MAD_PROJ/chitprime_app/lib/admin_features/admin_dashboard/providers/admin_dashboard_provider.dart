import 'package:flutter/material.dart';

class AdminDashboardProvider extends ChangeNotifier {
  bool isLoading = false;
  int totalUsers = 1248;
  int activeGroups = 87;
  double totalTransactions = 12500000;
  double platformRevenue = 375000;
  int activeAuctions = 5;
  int fraudAlerts = 3;
  double userGrowth = 12.5;
  double groupGrowth = 8.3;
  double revenueGrowth = 15.2;

  final List<Map<String, dynamic>> recentActivity = [
    {
      'icon': Icons.person_add_rounded,
      'color': Color(0xFF14B8A6),
      'title': 'New User Registered',
      'subtitle': 'Kavitha Reddy joined CHITPRIME',
      'time': '2 min ago',
    },
    {
      'icon': Icons.group_add_rounded,
      'color': Color(0xFF1E3A8A),
      'title': 'New Group Created',
      'subtitle': 'Textile Traders Fund created',
      'time': '15 min ago',
    },
    {
      'icon': Icons.warning_rounded,
      'color': Color(0xFFEF4444),
      'title': 'Fraud Alert',
      'subtitle': 'Suspicious activity detected for user ID 1045',
      'time': '1 hour ago',
    },
    {
      'icon': Icons.payments_rounded,
      'color': Color(0xFF10B981),
      'title': 'Large Transaction',
      'subtitle': '₹1,00,000 payout processed for Cycle 12',
      'time': '2 hours ago',
    },
  ];

  final List<Map<String, dynamic>> topGroups = [
    {'name': 'Premium Traders Club', 'fund': 300000, 'members': 28, 'completion': 0.4},
    {'name': 'Retailers Gold Circle', 'fund': 100000, 'members': 15, 'completion': 0.4},
    {'name': 'Small Business Fund', 'fund': 45000, 'members': 12, 'completion': 0.33},
  ];

  final List<double> revenueData = [28000, 32000, 29000, 35000, 38000, 37500];

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading = false;
    notifyListeners();
  }
}
