import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../groups/providers/groups_provider.dart';
import '../providers/payment_provider.dart';

class RepaymentScreen extends ConsumerStatefulWidget {
  final String groupId;
  const RepaymentScreen({super.key, required this.groupId});

  @override
  ConsumerState<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends ConsumerState<RepaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _method = 'UPI';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId)).valueOrNull;
    if (group == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repay Group Loan'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Group',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(group.groupName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    _infoRow('Contribution',
                        AppUtils.formatCurrency(group.monthlyContribution)),
                    _infoRow('Cycle',
                        'Cycle ${group.currentCycle}/${group.cycleDuration}'),
                  ]),
            ),
            const SizedBox(height: 20),
            const Text('Repayment Amount',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Amount', border: OutlineInputBorder()),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || amount <= 0)
                  return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text('Remark',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _remarkController,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Enter details for repayment',
                  border: OutlineInputBorder()),
              validator: (value) =>
                  value?.trim().isEmpty == true ? 'Add a remark' : null,
            ),
            const SizedBox(height: 20),
            const Text('Payment Method',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...['UPI', 'Card', 'Net Banking']
                .map((method) => _methodTile(method))
                .toList(),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Submit Repayment',
              isLoading: _submitting,
              icon: Icons.payment_rounded,
              onPressed: _submit,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _methodTile(String method) {
    final isSelected = _method == method;
    return GestureDetector(
      onTap: () => setState(() => _method = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 1.5 : 1),
          color:
              isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.card,
        ),
        child: Row(children: [
          Expanded(
              child: Text(method,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary))),
          if (isSelected)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 20),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ]),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    final remark = _remarkController.text.trim();
    setState(() => _submitting = true);
    try {
      final result = await ref.read(paymentNotifierProvider.notifier).repay(
            groupId: widget.groupId,
            groupName: ref
                    .read(groupProvider(widget.groupId))
                    .valueOrNull
                    ?.groupName ??
                'Group',
            amount: amount,
            method: _method,
            remark: remark,
          );
      if (context.mounted) {
        context.push('/payment/success', extra: result);
      }
    } catch (e) {
      if (context.mounted)
        showSnack(context, 'Repayment failed. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
