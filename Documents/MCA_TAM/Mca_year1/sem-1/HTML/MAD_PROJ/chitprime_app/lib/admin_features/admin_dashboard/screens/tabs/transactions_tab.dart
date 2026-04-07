import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../transactions/providers/transaction_provider.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Column(
      children: [
        _buildFilters(context, provider),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.filteredTransactions.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions found')
                  : RefreshIndicator(
                      onRefresh: () => provider.loadTransactions(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredTransactions.length,
                        itemBuilder: (_, i) => _TxnCard(
                            txn: provider.filteredTransactions[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, TransactionProvider provider) {
    final statuses = ['all', 'success', 'pending', 'failed'];
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: statuses.length,
        itemBuilder: (_, i) {
          final s = statuses[i];
          return GestureDetector(
            onTap: () => provider.setStatusFilter(s),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                s[0].toUpperCase() + s.substring(1),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TxnCard extends StatelessWidget {
  final dynamic txn;
  const _TxnCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final statusColor = txn.status == 'success'
        ? AppColors.success
        : txn.status == 'pending'
            ? AppColors.warning
            : AppColors.error;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              txn.status == 'success'
                  ? Icons.check_circle_rounded
                  : txn.status == 'pending'
                      ? Icons.pending_rounded
                      : Icons.cancel_rounded,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.groupName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                Text('Cycle ${txn.cycleNumber}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                if (txn.transactionId.isNotEmpty)
                  Text('TXN: ${txn.transactionId}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                if (txn.paymentDate != null)
                  Text(AppUtils.formatDateTime(txn.paymentDate!),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppUtils.formatCurrency(txn.amount),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              StatusBadge(
                  label: txn.status.toUpperCase(), color: statusColor),
              if (txn.paymentMethod.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(txn.paymentMethod,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
