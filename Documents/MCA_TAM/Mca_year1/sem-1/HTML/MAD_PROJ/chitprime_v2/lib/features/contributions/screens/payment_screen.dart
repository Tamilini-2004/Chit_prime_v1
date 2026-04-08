import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/payment_provider.dart';
import '../../groups/providers/groups_provider.dart';
import '../../auth/providers/auth_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String groupId;
  const PaymentScreen({super.key, required this.groupId});
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _method = 'UPI';
  bool _paying = false;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId)).valueOrNull;
    if (group == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(group.groupName),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        bottom: TabBar(controller: _tab, tabs: const [Tab(text: 'Pay Now'), Tab(text: 'History')]),
      ),
      body: TabBarView(controller: _tab, children: [
        _payNow(context, group),
        _history(),
      ]),
    );
  }

  Widget _payNow(BuildContext context, dynamic group) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        AppCard(gradient: AppColors.primaryGradient, child: Column(children: [
          const Text('Amount to Pay', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(AppUtils.formatCurrency(group.monthlyContribution), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${group.groupName} • Cycle ${group.currentCycle}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ])),
        const SizedBox(height: 20),
        const Align(alignment: Alignment.centerLeft, child: Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        const SizedBox(height: 12),
        ...[('UPI', Icons.account_balance_wallet_rounded, 'Google Pay, PhonePe, Paytm'), ('Card', Icons.credit_card_rounded, 'Debit / Credit Card'), ('Net Banking', Icons.account_balance_rounded, 'All major banks')].map((m) => _methodCard(m.$1, m.$2, m.$3)),
        const SizedBox(height: 16),
        if (_method == 'UPI') _upiApps(context),
        const SizedBox(height: 16),
        AppCard(child: Column(children: [
          _sumRow('Contribution', AppUtils.formatCurrency(group.monthlyContribution)),
          _sumRow('Processing Fee', 'FREE', valueColor: AppColors.success),
          const Divider(height: 16),
          _sumRow('Total Payable', AppUtils.formatCurrency(group.monthlyContribution), bold: true),
        ])),
        const SizedBox(height: 20),
        GradientButton(
          label: 'Pay ${AppUtils.formatCurrency(group.monthlyContribution)}',
          isLoading: _paying,
          onPressed: () => _pay(context, group),
          icon: Icons.lock_rounded,
        ),
        const SizedBox(height: 10),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_rounded, size: 14, color: AppColors.textSecondary), SizedBox(width: 6),
          Text('256-bit SSL • RBI Compliant', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _upiApps(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quick Pay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ('GPay', Icons.g_mobiledata_rounded, const Color(0xFF4285F4)),
        ('PhonePe', Icons.phone_android_rounded, const Color(0xFF5F259F)),
        ('Paytm', Icons.payment_rounded, const Color(0xFF00BAF2)),
        ('BHIM', Icons.account_balance_rounded, const Color(0xFF138808)),
      ].map((a) => GestureDetector(
        onTap: () => showSnack(context, 'Opening ${a.$1}...'),
        child: Column(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: a.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: a.$3.withOpacity(0.3))), child: Icon(a.$2, color: a.$3, size: 26)),
          const SizedBox(height: 4),
          Text(a.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      )).toList()),
    ]);
  }

  Widget _methodCard(String method, IconData icon, String subtitle) {
    final sel = method == _method;
    return GestureDetector(
      onTap: () => setState(() => _method = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary.withOpacity(0.06) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? AppColors.primary : AppColors.divider, width: sel ? 1.5 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: sel ? AppColors.primary.withOpacity(0.1) : AppColors.inputFill, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: sel ? AppColors.primary : AppColors.textSecondary, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(method, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: sel ? AppColors.primary : AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          if (sel) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
        ]),
      ),
    );
  }

  Widget _sumRow(String l, String v, {bool bold = false, Color? valueColor}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: 14, color: bold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
      Text(v, style: TextStyle(fontSize: 14, color: valueColor ?? (bold ? AppColors.primary : AppColors.textPrimary), fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
    ]),
  );

  Future<void> _pay(BuildContext context, dynamic group) async {
    setState(() => _paying = true);
    final result = await ref.read(paymentNotifierProvider.notifier).pay(
      groupId: widget.groupId, groupName: group.groupName,
      amount: group.monthlyContribution.toDouble(),
      cycleNumber: group.currentCycle, method: _method,
    );
    if (mounted) {
      setState(() => _paying = false);
      context.push('/payment/success', extra: result);
    }
  }

  Widget _history() {
    final contribs = ref.watch(myContributionsProvider).valueOrNull?.where((c) => c.groupId == widget.groupId).toList() ?? [];
    final total = contribs.where((c) => c.status == 'success').fold(0.0, (s, c) => s + c.amount);

    return ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(gradient: AppColors.primaryGradient, child: Row(children: [
        const Icon(Icons.payments_rounded, color: Colors.white, size: 28), const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total Paid', style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text(AppUtils.formatCurrency(total), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        ]),
      ])),
      const SizedBox(height: 12),
      ...contribs.map((c) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (c.status == 'success' ? AppColors.success : AppColors.error).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(c.status == 'success' ? Icons.check_circle_rounded : Icons.cancel_rounded, color: c.status == 'success' ? AppColors.success : AppColors.error, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cycle ${c.cycleNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
            if (c.paymentDate != null) Text(AppUtils.formatDate(c.paymentDate!), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('via ${c.paymentMethod}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('TXN: ${c.transactionId}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(AppUtils.formatCurrency(c.amount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
            StatusBadge(label: c.status.toUpperCase(), color: c.status == 'success' ? AppColors.success : AppColors.error),
          ]),
        ]),
      )),
    ]);
  }
}
