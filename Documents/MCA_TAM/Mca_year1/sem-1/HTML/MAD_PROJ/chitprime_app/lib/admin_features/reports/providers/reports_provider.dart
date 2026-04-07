import 'package:flutter/material.dart';

class ReportsProvider extends ChangeNotifier {
  bool isGenerating = false;
  String selectedReport = 'daily_transactions';
  DateTimeRange? dateRange;

  final List<Map<String, dynamic>> prebuiltReports = [
    {'id': 'daily_transactions', 'title': 'Daily Transaction Summary', 'icon': Icons.receipt_long_rounded, 'color': Color(0xFF1E3A8A)},
    {'id': 'monthly_revenue', 'title': 'Monthly Revenue Report', 'icon': Icons.bar_chart_rounded, 'color': Color(0xFF14B8A6)},
    {'id': 'user_growth', 'title': 'User Growth Report', 'icon': Icons.people_rounded, 'color': Color(0xFF10B981)},
    {'id': 'group_performance', 'title': 'Group Performance Report', 'icon': Icons.group_rounded, 'color': Color(0xFFF59E0B)},
    {'id': 'payment_collection', 'title': 'Payment Collection Rate', 'icon': Icons.payments_rounded, 'color': Color(0xFF8B5CF6)},
    {'id': 'default_recovery', 'title': 'Default & Recovery Report', 'icon': Icons.warning_rounded, 'color': Color(0xFFEF4444)},
  ];

  Future<void> generateReport(String reportId) async {
    isGenerating = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    isGenerating = false;
    notifyListeners();
  }
}
