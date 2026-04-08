import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../features/contributions/providers/payment_provider.dart';
import '../../../../features/groups/providers/groups_provider.dart';
import 'overview_tab.dart';

class ReportsTab extends ConsumerWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contribs = ref.watch(allContributionsProvider).valueOrNull ?? [];
    final totalRevenue = contribs.where((c) => c.status == 'success').fold(0.0, (s, c) => s + c.amount * 0.03);
    final totalCollected = contribs.where((c) => c.status == 'success').fold(0.0, (s, c) => s + c.amount);

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Summary cards
      Row(children: [
        Expanded(child: StatCard(label: 'Total Revenue', value: AppUtils.formatCurrency(totalRevenue), icon: Icons.currency_rupee_rounded, iconColor: AppColors.success, iconBg: AppColors.success.withOpacity(0.1))),
        const SizedBox(width: 10),
        Expanded(child: StatCard(label: 'Total Collected', value: AppUtils.formatCurrency(totalCollected), icon: Icons.payments_rounded, iconColor: AppColors.primary, iconBg: AppColors.primary.withOpacity(0.1))),
      ]),
      const SizedBox(height: 16),

      // Revenue chart
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Revenue Trend (6 months)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        SizedBox(height: 140, child: BarChart(BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
              const months = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
              final i = v.toInt();
              if (i < 0 || i >= months.length) return const SizedBox();
              return Text(months[i], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
            })),
          ),
          barGroups: [28000.0, 32000.0, 29000.0, 35000.0, 38000.0, totalRevenue.clamp(1000.0, 50000.0)].asMap().entries.map((e) =>
            BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.toDouble(), color: e.key == 5 ? AppColors.primary : AppColors.primary.withOpacity(0.4), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))])
          ).toList(),
        ))),
      ])),
      const SizedBox(height: 16),

      // Pre-built reports
      const SectionHeader(title: 'Pre-built Reports'),
      const SizedBox(height: 12),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
        children: [
          ('Daily Transactions', Icons.receipt_long_rounded, AppColors.primary),
          ('Monthly Revenue', Icons.bar_chart_rounded, AppColors.secondary),
          ('User Growth', Icons.people_rounded, AppColors.success),
          ('Group Performance', Icons.group_rounded, AppColors.accent),
          ('Payment Collection', Icons.payments_rounded, const Color(0xFF8B5CF6)),
          ('Default & Recovery', Icons.warning_rounded, AppColors.error),
        ].map((r) => GestureDetector(
          onTap: () => showSnack(context, 'Generating ${r.$1} report...'),
          child: AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: r.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(r.$2, color: r.$3, size: 20)),
            Text(r.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
            Row(children: [Icon(Icons.download_rounded, size: 12, color: r.$3), const SizedBox(width: 4), Text('Generate', style: TextStyle(fontSize: 11, color: r.$3, fontWeight: FontWeight.w500))]),
          ])),
        )).toList(),
      ),
      const SizedBox(height: 16),

      // Export options
      const SectionHeader(title: 'Export Options'),
      const SizedBox(height: 12),
      AppCard(child: Column(children: [
        ...[('PDF Report', Icons.picture_as_pdf_rounded, AppColors.error), ('Excel Spreadsheet', Icons.table_chart_rounded, AppColors.success), ('CSV Data', Icons.data_object_rounded, AppColors.secondary), ('Schedule Email', Icons.schedule_send_rounded, AppColors.primary)]
            .map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: e.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(e.$2, color: e.$3, size: 20)),
              title: Text(e.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
              onTap: () => showSnack(context, '${e.$1} export started...'),
            )),
      ])),
    ]);
  }
}
