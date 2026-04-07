import 'package:flutter/material.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repo;
  List<ContributionModel> _contributions = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  PaymentProvider(this._repo);

  List<ContributionModel> get contributions => _contributions;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  Future<void> loadContributions(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _contributions = await _repo.getUserContributions(userId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<ContributionModel?> processPayment({
    required String groupId,
    required String userId,
    required double amount,
    required String paymentMethod,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repo.processPayment(
        groupId: groupId,
        userId: userId,
        amount: amount,
        paymentMethod: paymentMethod,
      );
      _contributions.insert(0, result);
      _isProcessing = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }
}
