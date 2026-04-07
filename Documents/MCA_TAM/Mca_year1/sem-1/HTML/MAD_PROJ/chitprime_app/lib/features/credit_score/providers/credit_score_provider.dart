import 'package:flutter/material.dart';

class CreditScoreProvider extends ChangeNotifier {
  int score = 820;
  String rating = 'Excellent';
  String riskLevel = 'Low';
  int percentile = 92;
  int trendChange = 15;
  bool isLoading = false;

  final List<Map<String, dynamic>> factors = [
    {'label': 'Payment History', 'weight': '40%', 'value': 0.95, 'icon': Icons.payment_rounded},
    {'label': 'Contribution Consistency', 'weight': '25%', 'value': 0.90, 'icon': Icons.repeat_rounded},
    {'label': 'Group Participation', 'weight': '20%', 'value': 0.85, 'icon': Icons.group_rounded},
    {'label': 'Auction Behavior', 'weight': '15%', 'value': 0.80, 'icon': Icons.gavel_rounded},
  ];

  final List<double> trendData = [720, 740, 760, 780, 805, 820];

  final List<Map<String, dynamic>> insights = [
    {
      'type': 'positive',
      'icon': Icons.check_circle_rounded,
      'title': 'Perfect Payment Record',
      'message': 'You have never missed a payment. Keep it up!',
    },
    {
      'type': 'positive',
      'icon': Icons.star_rounded,
      'title': 'Active Participation',
      'message': 'You actively participate in group auctions.',
    },
    {
      'type': 'improve',
      'icon': Icons.lightbulb_rounded,
      'title': 'Join More Groups',
      'message': 'Joining 1 more group can boost your score by 20 points.',
    },
    {
      'type': 'improve',
      'icon': Icons.trending_up_rounded,
      'title': 'Increase Auction Participation',
      'message': 'Bidding in more auctions improves your score.',
    },
  ];

  Future<void> loadScore(String userId) async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading = false;
    notifyListeners();
  }
}
