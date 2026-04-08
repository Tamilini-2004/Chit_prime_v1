import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/shared_widgets.dart';
import 'overview_tab.dart';

class FraudTab extends ConsumerWidget {
  const FraudTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(allFraudAlertsProvider).valueOrNull ?? [];
    final high = alerts.where((a) => a.severity == 'high').length;
    final medium = alerts.where((a) => a.severity == 'medium').length;
    final low = alerts.where((a) => a.severity == 'low').length;
    final open = alerts.where((a) => a.status == 'open').length;

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Summary
      Row(children: [
        Expanded(child: _summaryCard('High', '$high', AppColors.error, Icons.warning_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('Medium', '$medium', AppColors.warning, Icons.info_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('Low', '$low', AppColors.accent, Icons.notifications_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('Open', '$open', AppColors.primary, Icons.pending_rounded)),
      ]),
      const SizedBox(height: 16),
      const SectionHeader(title: 'Active Alerts'),
      const SizedBox(height: 12),
      if (alerts.isEmpty)
        const AppEmptyState(icon: Icons.security_rounded, title: 'No fraud alerts', subtitle: 'Platform is secure!')
      else
        ...alerts.map((a) => _AlertCard(alert: a)),
      const SizedBox(height: 16),
      const SectionHeader(title: 'Prevention Tools'),
      const SizedBox(height: 12),
      AppCard(child: Column(children: [
        ...[
          ('AI Detection Model', Icons.psychology_rounded, AppColors.primary),
          ('Velocity Checks', Icons.speed_rounded, AppColors.secondary),
          ('Document Verification', Icons.verified_rounded, AppColors.success),
          ('Blacklist Management', Icons.block_rounded, AppColors.error),
          ('Audit Logs', Icons.history_rounded, AppColors.accent),
        ].map((t) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: t.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(t.$2, color: t.$3, size: 18)),
          title: Text(t.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          onTap: () => showSnack(context, '${t.$1} settings opened'),
        )),
      ])),
    ]);
  }

  Widget _summaryCard(String label, String count, Color color, IconData icon) {
    return AppCard(padding: const EdgeInsets.all(12), child: Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 6),
      Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]));
  }
}

class _AlertCard extends StatelessWidget {
  final dynamic alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final severityColor = alert.severity == 'high' ? AppColors.error : alert.severity == 'medium' ? AppColors.warning : AppColors.accent;
    final isResolved = alert.status == 'resolved';

    return AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: severityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.warning_rounded, color: severityColor, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(alert.alertType, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
          Text(alert.userName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusBadge(label: alert.severity.toUpperCase(), color: severityColor),
          const SizedBox(height: 4),
          StatusBadge(label: alert.status.toUpperCase(), color: isResolved ? AppColors.success : alert.status == 'investigating' ? AppColors.warning : AppColors.error),
        ]),
      ]),
      const SizedBox(height: 10),
      Text(alert.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary), const SizedBox(width: 6),
          Expanded(child: Text('AI Confidence: ${(alert.aiConfidence * 100).toInt()}% • ${AppUtils.timeAgo(alert.detectedAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
        ])),
      if (!isResolved) ...[
        const SizedBox(height: 10),
        Row(children: [
          if (alert.status == 'open') Expanded(child: _btn(context, 'Investigate', AppColors.warning, () => _updateStatus(context, alert.alertId, 'investigating'))),
          if (alert.status == 'open') const SizedBox(width: 8),
          Expanded(child: _btn(context, 'Resolve', AppColors.success, () => _updateStatus(context, alert.alertId, 'resolved'))),
          const SizedBox(width: 8),
          Expanded(child: _btn(context, 'False Positive', AppColors.textSecondary, () => _updateStatus(context, alert.alertId, 'false_positive'))),
        ]),
      ],
    ]));
  }

  Widget _btn(BuildContext context, String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
      child: Center(child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)))),
  );

  Future<void> _updateStatus(BuildContext context, String alertId, String status) async {
    await FirebaseFirestore.instance.collection('fraud_alerts').doc(alertId).update({
      'status': status,
      if (status == 'resolved') 'resolvedAt': FieldValue.serverTimestamp(),
    });
    if (context.mounted) showSnack(context, 'Alert marked as $status');
  }
}
