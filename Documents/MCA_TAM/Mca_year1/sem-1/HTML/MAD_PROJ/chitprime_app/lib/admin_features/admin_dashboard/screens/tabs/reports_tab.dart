import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../reports/providers/reports_provider.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Pre-built Reports'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: provider.prebuiltReports.length,
          itemBuilder: (_, i) {
            final r = provider.prebuiltReports[i];
            return _ReportCard(
              report: r,
              onGenerate: () => provider.generateReport(r['id'] as String),
              isGenerating: provider.isGenerating &&
                  provider.selectedReport == r['id'],
            );
          },
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Export Options'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              ...[
                ('PDF Report', Icons.picture_as_pdf_rounded, AppColors.error),
                ('Excel Spreadsheet', Icons.table_chart_rounded, AppColors.success),
                ('CSV Data', Icons.data_object_rounded, AppColors.secondary),
                ('Schedule Email Report', Icons.schedule_send_rounded, AppColors.primary),
              ].map((e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: e.$3.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(e.$2, color: e.$3, size: 20),
                    ),
                    title: Text(e.$1,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textSecondary),
                    onTap: () {},
                  )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Analytics Dashboards'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              ...[
                ('User Behavior Analytics', Icons.person_search_rounded),
                ('Group Lifecycle Analysis', Icons.timeline_rounded),
                ('Payment Patterns', Icons.payments_rounded),
                ('Credit Score Distribution', Icons.psychology_rounded),
              ].map((e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(e.$2, color: AppColors.primary, size: 20),
                    ),
                    title: Text(e.$1,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textSecondary),
                    onTap: () {},
                  )),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onGenerate;
  final bool isGenerating;

  const _ReportCard({
    required this.report,
    required this.onGenerate,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    final color = report['color'] as Color;
    return AppCard(
      onTap: onGenerate,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isGenerating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: color),
                  )
                : Icon(report['icon'] as IconData, color: color, size: 20),
          ),
          Text(
            report['title'] as String,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(Icons.download_rounded, size: 12, color: color),
              const SizedBox(width: 4),
              Text('Generate',
                  style: TextStyle(
                      fontSize: 11, color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
