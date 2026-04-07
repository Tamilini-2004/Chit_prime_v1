import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/payment_model.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  int activeGroups = 2;
  double totalContributed = 64000;
  double upcomingPayout = 100000;
  int creditScore = 820;
  List<ContributionModel> pendingPayments = [];
  List<Map<String, dynamic>> recentActivity = [];

  bool get isLoading => _isLoading;

  Future<void> loadDashboard(String userId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    pendingPayments = [
      ContributionModel(
        contributionId: 'con_003',
        groupId: 'grp_002',
        groupName: 'Small Business Fund',
        userId: userId,
        amount: 3000,
        cycleNumber: 5,
        paymentMethod: '',
        transactionId: '',
        status: 'pending',
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
      ContributionModel(
        contributionId: 'con_005',
        groupId: 'grp_001',
        groupName: 'Retailers Gold Circle',
        userId: userId,
        amount: 5000,
        cycleNumber: 9,
        paymentMethod: '',
        transactionId: '',
        status: 'pending',
        dueDate: DateTime.now().add(const Duration(days: 7)),
      ),
      ContributionModel(
        contributionId: 'con_006',
        groupId: 'grp_004',
        groupName: 'Kirana Store Network',
        userId: userId,
        amount: 2000,
        cycleNumber: 2,
        paymentMethod: '',
        transactionId: '',
        status: 'pending',
        dueDate: DateTime.now().add(const Duration(days: 12)),
      ),
    ];
    recentActivity = [
      {
        'icon': Icons.check_circle_rounded,
        'color': AppColors.success,
        'title': 'Payment Confirmed',
        'subtitle': '₹5,000 paid for Retailers Gold Circle',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'icon': Icons.gavel_rounded,
        'color': AppColors.primary,
        'title': 'Auction Started',
        'subtitle': 'Cycle 9 auction is now live',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        'icon': Icons.person_add_rounded,
        'color': AppColors.secondary,
        'title': 'New Member Joined',
        'subtitle': 'Kavitha joined Retailers Gold Circle',
        'time': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];
    _isLoading = false;
    notifyListeners();
  }
}


