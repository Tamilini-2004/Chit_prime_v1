import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/notification_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../admin_auth/providers/admin_auth_provider.dart';
import 'tabs/overview_tab.dart';
import 'tabs/users_tab.dart';
import 'tabs/groups_tab.dart';
import 'tabs/transactions_tab.dart';
import 'tabs/fraud_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/settings_tab.dart';

// Admin-wide fraud alerts stream
final adminFraudAlertsProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('fraud_alerts')
      .orderBy('detectedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(FraudAlertModel.fromDoc).toList());
});

class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});
  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _index = 0;

  static const _tabs = [
    (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Overview'),
    (Icons.people_rounded, Icons.people_outline_rounded, 'Users'),
    (Icons.group_rounded, Icons.group_outlined, 'Groups'),
    (Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Txns'),
    (Icons.security_rounded, Icons.security_outlined, 'Fraud'),
    (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Reports'),
    (Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final fraudAlerts = ref.watch(adminFraudAlertsProvider).valueOrNull ?? [];
    final openAlerts = fraudAlerts.where((a) => a.status == 'open').length;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CHITPRIME Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(user?.role.toUpperCase() ?? 'ADMIN', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ]),
        actions: [
          if (openAlerts > 0)
            Stack(children: [
              IconButton(icon: const Icon(Icons.notifications_rounded), onPressed: () => setState(() => _index = 4)),
              Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                child: Text('$openAlerts', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))),
            ]),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(adminAuthNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/admin');
            },
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: const [
        OverviewTab(), UsersTab(), GroupsTab(), TransactionsTab(), FraudTab(), ReportsTab(), SettingsTab(),
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: AppColors.card, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))]),
        child: SafeArea(child: SizedBox(height: 60, child: Row(
          children: _tabs.asMap().entries.map((e) {
            final i = e.key; final t = e.value;
            final sel = _index == i;
            final showBadge = i == 4 && openAlerts > 0;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _index = i),
              behavior: HitTestBehavior.opaque,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Stack(clipBehavior: Clip.none, children: [
                  Icon(sel ? t.$1 : t.$2, color: sel ? AppColors.primary : AppColors.textSecondary, size: 22),
                  if (showBadge) Positioned(right: -4, top: -4, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))),
                ]),
                const SizedBox(height: 2),
                Text(t.$3, style: TextStyle(fontSize: 10, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppColors.primary : AppColors.textSecondary)),
              ]),
            ));
          }).toList(),
        ))),
      ),
    );
  }
}
