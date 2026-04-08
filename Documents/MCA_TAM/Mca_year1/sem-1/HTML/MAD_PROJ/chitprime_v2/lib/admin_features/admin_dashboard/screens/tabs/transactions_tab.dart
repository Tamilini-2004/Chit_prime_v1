import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../features/contributions/providers/payment_provider.dart';

class TransactionsTab extends ConsumerStatefulWidget {
  const TransactionsTab({super.key});
  @override
  ConsumerState<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<TransactionsTab> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allContributionsProvider).valueOrNull ?? [];
    final filtered = _filter == 'all' ? all : all.where((c) => c.status == _filter).toList();
    final totalRevenue = all.where((c) => c.status == 'success').fold(0.0, (s, c) => s + c.amount * 0.03);

    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: AppCard(gradient: AppColors.primaryGradient, child: Row(children: [
        const Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 28), const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Platform Revenue', style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text(AppUtils.formatCurrency(totalRevenue), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          Text('From ${all.where((c) => c.status == 'success').length} successful transactions', style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ]),
      ]))),
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['all', 'success', 'pending', 'failed'].map((f) => GestureDetector(
          onTap: () => setState(() => _filter = f),
          child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: _filter == f ? AppColors.primary : AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(f.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _filter == f ? Colors.white : AppColors.primary))),
        )).toList(),
      )),
      Expanded(child: filtered.isEmpty
          ? const AppEmptyState(icon: Icons.receipt_long_outlined, title: 'No transactions')
          : ListView.builder(padding: const EdgeInsets.all(16), itemCount: filtered.length, itemBuilder: (_, i) {
              final c = filtered[i];
              final statusColor = c.status == 'success' ? AppColors.success : c.status == 'pending' ? AppColors.warning : AppColors.error;
              return AppCard(padding: const EdgeInsets.all(14), child: Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(c.status == 'success' ? Icons.check_circle_rounded : c.status == 'pending' ? Icons.pending_rounded : Icons.cancel_rounded, color: statusColor, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                  Text(c.groupName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text('Cycle ${c.cycleNumber} • ${c.paymentMethod}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('TXN: ${c.transactionId}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  if (c.paymentDate != null) Text(AppUtils.formatDateTime(c.paymentDate!), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(AppUtils.formatCurrency(c.amount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  StatusBadge(label: c.status.toUpperCase(), color: statusColor),
                  const SizedBox(height: 4),
                  // Admin action: mark failed as success
                  if (c.status == 'failed')
                    GestureDetector(
                      onTap: () async {
                        await FirebaseFirestore.instance.collection('contributions').doc(c.contributionId).update({'status': 'success'});
                        if (context.mounted) showSnack(context, 'Transaction marked as success');
                      },
                      child: const Text('Fix', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                ]),
              ]));
            })),
    ]);
  }
}
