import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/payment_provider.dart';

class PaymentScreen extends StatefulWidget {
  final String groupId;
  const PaymentScreen({super.key, required this.groupId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMethod = 'UPI';

  final Map<String, Map<String, dynamic>> _groupData = {
    'grp_001': {'name': 'Retailers Gold Circle', 'amount': 5000.0, 'cycle': 9, 'due': 'Aug 10, 2024'},
    'grp_002': {'name': 'Small Business Fund', 'amount': 3000.0, 'cycle': 5, 'due': 'Aug 12, 2024'},
    'grp_003': {'name': 'Premium Traders Club', 'amount': 10000.0, 'cycle': 12, 'due': 'Aug 15, 2024'},
    'grp_004': {'name': 'Kirana Store Network', 'amount': 2000.0, 'cycle': 2, 'due': 'Aug 20, 2024'},
  };

  Map<String, dynamic> get _group =>
      _groupData[widget.groupId] ?? {'name': 'Chit Group', 'amount': 5000.0, 'cycle': 1, 'due': 'Aug 10, 2024'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) context.read<PaymentProvider>().loadContributions(user.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_group['name'] as String),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pay Now'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PayNowTab(
            groupId: widget.groupId,
            groupName: _group['name'] as String,
            amount: _group['amount'] as double,
            cycle: _group['cycle'] as int,
            dueDate: _group['due'] as String,
            selectedMethod: _selectedMethod,
            onMethodChanged: (m) => setState(() => _selectedMethod = m),
          ),
          _PaymentHistoryTab(groupId: widget.groupId, groupName: _group['name'] as String),
        ],
      ),
    );
  }
}

class _PayNowTab extends StatelessWidget {
  final String groupId;
  final String groupName;
  final double amount;
  final int cycle;
  final String dueDate;
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;

  const _PayNowTab({
    required this.groupId,
    required this.groupName,
    required this.amount,
    required this.cycle,
    required this.dueDate,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount card
          AppCard(
            gradient: AppColors.primaryGradient,
            child: Column(
              children: [
                const Text('Amount to Pay', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text(AppUtils.formatCurrency(amount),
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('$groupName • Cycle $cycle',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white60),
                    const SizedBox(width: 4),
                    Text('Due: $dueDate', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment methods
          const Text('Select Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...[
            ('UPI', Icons.account_balance_wallet_rounded, 'Google Pay, PhonePe, Paytm'),
            ('Card', Icons.credit_card_rounded, 'Debit / Credit Card'),
            ('Net Banking', Icons.account_balance_rounded, 'All major banks'),
          ].map((m) => _methodCard(m.$1, m.$2, m.$3)),
          const SizedBox(height: 20),

          // Summary
          AppCard(
            child: Column(
              children: [
                _summaryRow('Contribution Amount', AppUtils.formatCurrency(amount)),
                _summaryRow('Processing Fee', 'FREE', valueColor: AppColors.success),
                _summaryRow('GST', '₹0'),
                const Divider(height: 20),
                _summaryRow('Total Payable', AppUtils.formatCurrency(amount), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pay button
          Consumer<PaymentProvider>(
            builder: (_, provider, __) => GradientButton(
              label: 'Pay ${AppUtils.formatCurrency(amount)}',
              isLoading: provider.isProcessing,
              onPressed: () => _pay(context, provider),
              icon: Icons.lock_rounded,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text('256-bit SSL encryption • RBI Compliant',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 20),

          // UPI apps row (only show for UPI)
          if (selectedMethod == 'UPI') _buildUpiApps(context),
        ],
      ),
    );
  }

  Widget _buildUpiApps(BuildContext context) {
    final apps = [
      ('GPay', Icons.g_mobiledata_rounded, const Color(0xFF4285F4)),
      ('PhonePe', Icons.phone_android_rounded, const Color(0xFF5F259F)),
      ('Paytm', Icons.payment_rounded, const Color(0xFF00BAF2)),
      ('BHIM', Icons.account_balance_rounded, const Color(0xFF138808)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Pay with UPI',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: apps.map((a) => GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${a.$1}...'),
                backgroundColor: a.$3,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 1),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: a.$3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: a.$3.withOpacity(0.3)),
                  ),
                  child: Icon(a.$2, color: a.$3, size: 28),
                ),
                const SizedBox(height: 6),
                Text(a.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _methodCard(String method, IconData icon, String subtitle) {
    final isSelected = method == selectedMethod;
    return GestureDetector(
      onTap: () => onMethodChanged(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.06) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 1.5 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: bold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
          Text(value, style: TextStyle(fontSize: 14, color: valueColor ?? (bold ? AppColors.primary : AppColors.textPrimary), fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _pay(BuildContext context, PaymentProvider provider) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final result = await provider.processPayment(
      groupId: groupId,
      userId: user.userId,
      amount: amount,
      paymentMethod: selectedMethod,
    );
    if (result != null && context.mounted) {
      context.push(AppRoutes.paymentSuccess, extra: {
        'groupName': groupName,
        'amount': amount,
        'transactionId': result.transactionId,
        'date': result.paymentDate ?? DateTime.now(),
        'method': selectedMethod,
      });
    }
  }
}

class _PaymentHistoryTab extends StatelessWidget {
  final String groupId;
  final String groupName;
  const _PaymentHistoryTab({required this.groupId, required this.groupName});

  List<Map<String, dynamic>> get _fakeHistory {
    final Map<String, List<Map<String, dynamic>>> data = {
      'grp_001': [
        {'cycle': 9, 'amount': 5000.0, 'date': DateTime(2024, 8, 5), 'method': 'UPI', 'txn': 'TXN20240805001', 'status': 'success'},
        {'cycle': 8, 'amount': 5000.0, 'date': DateTime(2024, 7, 6), 'method': 'UPI', 'txn': 'TXN20240706001', 'status': 'success'},
        {'cycle': 7, 'amount': 5000.0, 'date': DateTime(2024, 6, 5), 'method': 'Net Banking', 'txn': 'TXN20240605001', 'status': 'success'},
        {'cycle': 6, 'amount': 5000.0, 'date': DateTime(2024, 5, 7), 'method': 'UPI', 'txn': 'TXN20240507001', 'status': 'success'},
        {'cycle': 5, 'amount': 5000.0, 'date': DateTime(2024, 4, 6), 'method': 'Card', 'txn': 'TXN20240406001', 'status': 'success'},
        {'cycle': 4, 'amount': 5000.0, 'date': DateTime(2024, 3, 5), 'method': 'UPI', 'txn': 'TXN20240305001', 'status': 'success'},
        {'cycle': 3, 'amount': 5000.0, 'date': DateTime(2024, 2, 6), 'method': 'UPI', 'txn': 'TXN20240206001', 'status': 'failed'},
        {'cycle': 2, 'amount': 5000.0, 'date': DateTime(2024, 1, 8), 'method': 'Net Banking', 'txn': 'TXN20240108001', 'status': 'success'},
      ],
      'grp_002': [
        {'cycle': 5, 'amount': 3000.0, 'date': DateTime(2024, 8, 8), 'method': 'UPI', 'txn': 'TXN20240808002', 'status': 'pending'},
        {'cycle': 4, 'amount': 3000.0, 'date': DateTime(2024, 7, 8), 'method': 'Net Banking', 'txn': 'TXN20240708002', 'status': 'success'},
        {'cycle': 3, 'amount': 3000.0, 'date': DateTime(2024, 6, 7), 'method': 'UPI', 'txn': 'TXN20240607002', 'status': 'success'},
        {'cycle': 2, 'amount': 3000.0, 'date': DateTime(2024, 5, 8), 'method': 'Card', 'txn': 'TXN20240508002', 'status': 'success'},
        {'cycle': 1, 'amount': 3000.0, 'date': DateTime(2024, 4, 7), 'method': 'UPI', 'txn': 'TXN20240407002', 'status': 'success'},
      ],
      'grp_003': [
        {'cycle': 12, 'amount': 10000.0, 'date': DateTime(2024, 8, 3), 'method': 'Net Banking', 'txn': 'TXN20240803003', 'status': 'success'},
        {'cycle': 11, 'amount': 10000.0, 'date': DateTime(2024, 7, 4), 'method': 'Net Banking', 'txn': 'TXN20240704003', 'status': 'success'},
        {'cycle': 10, 'amount': 10000.0, 'date': DateTime(2024, 6, 3), 'method': 'Card', 'txn': 'TXN20240603003', 'status': 'success'},
      ],
      'grp_004': [
        {'cycle': 2, 'amount': 2000.0, 'date': DateTime(2024, 8, 1), 'method': 'UPI', 'txn': 'TXN20240801004', 'status': 'success'},
        {'cycle': 1, 'amount': 2000.0, 'date': DateTime(2024, 7, 2), 'method': 'UPI', 'txn': 'TXN20240702004', 'status': 'success'},
      ],
    };
    return data[groupId] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final history = _fakeHistory;
    final totalPaid = history.where((h) => h['status'] == 'success').fold(0.0, (s, h) => s + (h['amount'] as double));
    final successCount = history.where((h) => h['status'] == 'success').length;
    final failedCount = history.where((h) => h['status'] == 'failed').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        AppCard(
          gradient: AppColors.primaryGradient,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.payments_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Paid', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(AppUtils.formatCurrency(totalPaid),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _statChip('${history.length}', 'Total', Colors.white)),
                  Expanded(child: _statChip('$successCount', 'Success', AppColors.success)),
                  Expanded(child: _statChip('$failedCount', 'Failed', AppColors.error)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Success', 'Pending', 'Failed'].map((f) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(f, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Payment list
        ...history.map((h) => _paymentCard(context, h)),
      ],
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _paymentCard(BuildContext context, Map<String, dynamic> h) {
    final status = h['status'] as String;
    final statusColor = status == 'success' ? AppColors.success : status == 'pending' ? AppColors.warning : AppColors.error;
    final statusIcon = status == 'success' ? Icons.check_circle_rounded : status == 'pending' ? Icons.pending_rounded : Icons.cancel_rounded;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cycle ${h['cycle']}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                    Text(AppUtils.formatDate(h['date'] as DateTime),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('via ${h['method']}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppUtils.formatCurrency(h['amount'] as double),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  StatusBadge(label: status.toUpperCase(), color: statusColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.receipt_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(child: Text('TXN: ${h['txn']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                GestureDetector(
                  onTap: () => _showReceipt(context, h),
                  child: const Row(
                    children: [
                      Icon(Icons.download_rounded, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Receipt', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReceipt(BuildContext context, Map<String, dynamic> h) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Payment Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text('Payment Successful', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _receiptRow('Group', groupName),
            _receiptRow('Cycle', 'Cycle ${h['cycle']}'),
            _receiptRow('Amount', AppUtils.formatCurrency(h['amount'] as double)),
            _receiptRow('Method', h['method'] as String),
            _receiptRow('Date', AppUtils.formatDate(h['date'] as DateTime)),
            _receiptRow('Transaction ID', h['txn'] as String),
            _receiptRow('Status', (h['status'] as String).toUpperCase()),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(children: [Icon(Icons.download_rounded, color: Colors.white, size: 16), SizedBox(width: 8), Text('Receipt downloaded!')]),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
