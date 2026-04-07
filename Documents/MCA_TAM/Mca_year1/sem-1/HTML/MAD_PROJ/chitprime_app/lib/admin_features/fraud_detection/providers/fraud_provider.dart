import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';

class FraudProvider extends ChangeNotifier {
  bool isLoading = false;

  final List<FraudAlertModel> _alerts = [
    FraudAlertModel(alertId: 'alert_001', userId: 'user_003', userName: 'Amit Patel', alertType: 'Duplicate Account', severity: 'high', description: 'Multiple accounts detected with same Aadhaar number', evidence: 'Aadhaar: XXXX1234 linked to 2 accounts', status: 'open', riskScore: 92, detectedAt: DateTime.now().subtract(const Duration(hours: 2))),
    FraudAlertModel(alertId: 'alert_002', userId: 'user_005', userName: 'Mohan Lal', alertType: 'Unusual Bidding Pattern', severity: 'medium', description: 'Suspicious bidding behavior detected in multiple auctions', evidence: 'Bid amounts consistently just above threshold', status: 'investigating', riskScore: 68, detectedAt: DateTime.now().subtract(const Duration(hours: 8))),
    FraudAlertModel(alertId: 'alert_003', userId: 'user_006', userName: 'Kavitha Reddy', alertType: 'Multiple Failed Payments', severity: 'low', description: '3 consecutive payment failures in the last 7 days', evidence: 'Payment failures on: Aug 1, Aug 3, Aug 5', status: 'open', riskScore: 45, detectedAt: DateTime.now().subtract(const Duration(days: 1))),
  ];

  List<FraudAlertModel> get alerts => _alerts;
  int get highAlerts => _alerts.where((a) => a.severity == 'high').length;
  int get mediumAlerts => _alerts.where((a) => a.severity == 'medium').length;
  int get lowAlerts => _alerts.where((a) => a.severity == 'low').length;
  int get openAlerts => _alerts.where((a) => a.status == 'open').length;

  Future<void> resolveAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _alerts.indexWhere((a) => a.alertId == alertId);
    if (index != -1) {
      final a = _alerts[index];
      _alerts[index] = FraudAlertModel(
        alertId: a.alertId, userId: a.userId, userName: a.userName,
        alertType: a.alertType, severity: a.severity, description: a.description,
        evidence: a.evidence, status: 'resolved', riskScore: a.riskScore,
        detectedAt: a.detectedAt, resolvedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> investigateAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _alerts.indexWhere((a) => a.alertId == alertId);
    if (index != -1) {
      final a = _alerts[index];
      _alerts[index] = FraudAlertModel(
        alertId: a.alertId, userId: a.userId, userName: a.userName,
        alertType: a.alertType, severity: a.severity, description: a.description,
        evidence: a.evidence, status: 'investigating', riskScore: a.riskScore,
        detectedAt: a.detectedAt,
      );
      notifyListeners();
    }
  }
}
