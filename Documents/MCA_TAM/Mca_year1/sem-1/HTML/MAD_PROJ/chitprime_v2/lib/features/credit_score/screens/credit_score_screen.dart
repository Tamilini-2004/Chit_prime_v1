import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../auth/providers/auth_provider.dart';

class CreditScoreScreen extends ConsumerWidget {
  const CreditScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final score = user?.creditScore ?? 650;
    final rating = AppUtils.creditRating(score);
    final ratingColor = score >= 800 ? AppColors.success : score >= 650 ? AppColors.secondary : score >= 500 ? AppColors.warning : AppColors.error;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 280, pinned: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                const Text('AI Credit Score', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const Text('Your financial trustworthiness', style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 20),
                CircularPercentIndicator(
                  radius: 70, lineWidth: 10, percent: (score / 1000).clamp(0.0, 1.0),
                  center: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('$score', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                    const Text('of 1000', style: TextStyle(fontSize: 11, color: Colors.white60)),
                  ]),
                  progressColor: AppColors.accent, backgroundColor: Colors.white24,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  StatusBadge(label: rating, color: ratingColor),
                  const SizedBox(width: 8),
                  StatusBadge(label: score >= 650 ? 'Low Risk' : 'High Risk', color: score >= 650 ? AppColors.success : AppColors.error),
                ]),
              ])),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _buildTrendChart(score),
            const SizedBox(height: 16),
            _buildFactors(score),
            const SizedBox(height: 16),
            _buildInsights(score),
            const SizedBox(height: 16),
            _buildHowCalculated(),
            const SizedBox(height: 24),
          ])),
        ),
      ]),
    );
  }

  Widget _buildTrendChart(int score) {
    final data = [score - 80, score - 60, score - 40, score - 20, score - 5, score.toDouble()];
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Score Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.trending_up_rounded, size: 14, color: AppColors.success), SizedBox(width: 4),
            Text('+15 pts', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
          ])),
      ]),
      const SizedBox(height: 16),
      SizedBox(height: 120, child: LineChart(LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
            const months = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
            final i = v.toInt();
            if (i < 0 || i >= months.length) return const SizedBox();
            return Text(months[i], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
          })),
        ),
        lineBarsData: [LineChartBarData(
          spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
          isCurved: true, color: AppColors.primary, barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
        )],
      ))),
    ]));
  }

  Widget _buildFactors(int score) {
    final factors = [
      ('Payment History', 0.40, (score * 0.95 / 1000).clamp(0.0, 1.0), Icons.payment_rounded),
      ('Contribution Consistency', 0.25, (score * 0.90 / 1000).clamp(0.0, 1.0), Icons.repeat_rounded),
      ('Group Participation', 0.20, (score * 0.85 / 1000).clamp(0.0, 1.0), Icons.group_rounded),
      ('Auction Behavior', 0.15, (score * 0.80 / 1000).clamp(0.0, 1.0), Icons.gavel_rounded),
    ];
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Score Factors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 16),
      ...factors.map((f) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(children: [
        Row(children: [
          Icon(f.$4, size: 18, color: AppColors.primary), const SizedBox(width: 8),
          Expanded(child: Text(f.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
          Text('${(f.$2 * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text('${(f.$3 * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: f.$3, backgroundColor: AppColors.divider, color: AppColors.primary, minHeight: 6)),
      ]))),
    ]));
  }

  Widget _buildInsights(int score) {
    final insights = [
      (true, Icons.check_circle_rounded, 'Perfect Payment Record', 'You have never missed a payment. Keep it up!'),
      (true, Icons.star_rounded, 'Active Participation', 'You actively participate in group auctions.'),
      (false, Icons.lightbulb_rounded, 'Join More Groups', 'Joining 1 more group can boost your score by 20 points.'),
      (false, Icons.trending_up_rounded, 'Increase Auction Participation', 'Bidding in more auctions improves your score.'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'AI-Powered Insights'),
      const SizedBox(height: 12),
      ...insights.map((i) {
        final color = i.$1 ? AppColors.success : AppColors.warning;
        return AppCard(padding: const EdgeInsets.all(14), child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(i.$2, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(i.$3, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
            Text(i.$4, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
        ]));
      }),
    ]);
  }

  Widget _buildHowCalculated() {
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('How Score is Calculated', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      const Text('Your CHITPRIME AI Credit Score is calculated using machine learning algorithms that analyze your financial behavior within the platform.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      const SizedBox(height: 12),
      ...['Payment History (40%): Timely payments boost your score', 'Contribution Consistency (25%): Regular contributions show reliability', 'Group Participation (20%): Active membership improves trust', 'Auction Behavior (15%): Fair bidding practices are rewarded']
          .map((s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.circle, size: 6, color: AppColors.primary), const SizedBox(width: 8),
            Expanded(child: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          ]))),
    ]));
  }
}
