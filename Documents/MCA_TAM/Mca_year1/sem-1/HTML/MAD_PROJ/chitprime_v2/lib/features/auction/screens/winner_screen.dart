import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/auction_provider.dart';

class WinnerScreen extends ConsumerWidget {
  final String auctionId;
  const WinnerScreen({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auction = ref.watch(auctionProvider(auctionId)).valueOrNull;
    if (auction == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => context.pop()),
                const Text('Auction Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
            Expanded(child: Container(
              decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(height: 20),
                Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: AppColors.accent, width: 3)),
                  child: const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 56)),
                const SizedBox(height: 20),
                const Text('🏆 Winner Announced!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(auction.groupName, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                AppCard(child: Column(children: [
                  CircleAvatar(radius: 32, backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(AppUtils.getInitials(auction.winnerName.isEmpty ? 'W' : auction.winnerName), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  const SizedBox(height: 12),
                  Text(auction.winnerName.isEmpty ? 'Winner' : auction.winnerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Congratulations!', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _row('Winning Bid', AppUtils.formatCurrency(auction.winningBid)),
                  _row('Total Fund', AppUtils.formatCurrency(auction.totalFund)),
                  _row('Cycle', 'Cycle ${auction.cycleNumber}'),
                  _row('Auction Type', auction.auctionType.toUpperCase()),
                ])),
                const Spacer(),
                GradientButton(label: 'Back to Home', onPressed: () => context.go('/dashboard'), icon: Icons.home_rounded),
              ]),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    ]),
  );
}
