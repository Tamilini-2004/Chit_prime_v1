import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  double commissionRate = 3.0;
  double gstRate = 18.0;
  int minGroupSize = 10;
  int maxGroupSize = 50;
  double minContribution = 1000;
  double maxContribution = 100000;
  int auctionDurationHours = 24;
  bool enforce2FA = true;
  int sessionTimeoutMinutes = 30;

  void updateCommission(double value) {
    commissionRate = value;
    notifyListeners();
  }

  void updateGst(double value) {
    gstRate = value;
    notifyListeners();
  }

  void updateMinGroupSize(int value) {
    minGroupSize = value;
    notifyListeners();
  }

  void updateMaxGroupSize(int value) {
    maxGroupSize = value;
    notifyListeners();
  }

  void toggle2FA(bool value) {
    enforce2FA = value;
    notifyListeners();
  }

  Future<void> saveSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
