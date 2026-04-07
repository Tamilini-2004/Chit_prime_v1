import 'package:flutter/material.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/repositories/payment_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final PaymentRepository _repo;
  List<ContributionModel> _transactions = [];
  bool isLoading = false;
  String _filterType = 'all';
  String _filterStatus = 'all';

  TransactionProvider(this._repo);

  List<ContributionModel> get filteredTransactions {
    return _transactions.where((t) {
      final matchesStatus =
          _filterStatus == 'all' || t.status == _filterStatus;
      return matchesStatus;
    }).toList();
  }

  void setTypeFilter(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    isLoading = true;
    notifyListeners();
    _transactions = await _repo.getAllTransactions();
    isLoading = false;
    notifyListeners();
  }
}
