import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/auction_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AuctionScreen extends ConsumerStatefulWidget {
  final String auctionId;
  const AuctionScreen({super.key, required this.auctionId});
  @override
  ConsumerState<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends ConsumerState<AuctionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _bidCtrl = TextEditingController();
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final auction = ref.read(auctionProvider(widget.auctionId)).valueOrNull;
      if (auction != null && mounted) setState(() => _remaining = auction.timeRemaining);
    });
  }

  @override
  void dispose() { _tab.dispose(); _bidCtrl.dispose(); _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auction = ref.watch(auctionProvider(widget.auctionId)).valueOrNull;
    final bids = ref.watch(liveBidsProvider(widget.auctionId)).valueOrNull ?? [];
    final highest = ref.watch(currentHighestProvider(widget.auctionId)).valueOrNull ?? 0.0;
    if (auction == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final isForeman = ref.watch(currentUserProvider).valueOrNull?.isForeman ?? false;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true, expandedHeight: 160,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => context.pop()),
            actions: [
              if (isForeman)
                TextButton(onPressed: () => _closeAuction(context), child: const Text('Close Auction', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600))),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                  Row(children: [
                    Expanded(child: Text(auction.groupName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
                    if (auction.isLive) _liveBadge(),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.timer_rounded, size: 14, color: Colors.white70), const SizedBox(width: 4),
                    Text(AppUtils.countdown(_remaining), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
                    const Spacer(),
                    Text('Fund: ${AppUtils.formatCurrency(auction.totalFund)}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  ]),
                ]),
              ),
            ),
            bottom: TabBar(controller: _tab, labelColor: Colors.white, unselectedLabelColor: Colors.white60, indicatorColor: AppColors.accent,
              tabs: const [Tab(text: 'Auction'), Tab(text: 'Lottery')]),
          ),
        ],
        body: TabBarView(controller: _tab, children: [
          _AuctionTab(auctionId: widget.auctionId, bids: bids, highest: highest, bidCtrl: _bidCtrl, onBid: () => _placeBid(context, highest)),
          _LotteryTab(auctionId: widget.auctionId, auction: auction),
        ]),
      ),
    );
  }

  Widget _liveBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.circle, size: 8, color: Colors.white), SizedBox(width: 4),
      Text('LIVE', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
    ]),
  );

  Future<void> _placeBid(BuildContext context, double highest) async {
    final amount = double.tryParse(_bidCtrl.text);
    if (amount == null || amount <= 0) { showSnack(context, 'Enter a valid bid amount', isError: true); return; }
    if (amount <= highest) { showSnack(context, 'Bid must be higher than ${AppUtils.formatCurrency(highest)}', isError: true); return; }
    await ref.read(auctionNotifierProvider.notifier).placeBid(auctionId: widget.auctionId, amount: amount);
    _bidCtrl.clear();
    if (context.mounted) showSnack(context, 'Bid of ${AppUtils.formatCurrency(amount)} placed! 🔨');
  }

  Future<void> _closeAuction(BuildContext context) async {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Close Auction & Select Winner'),
      content: const Text('This will select the winner and create a payout. Cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final payoutId = await ref.read(auctionNotifierProvider.notifier).closeAuctionAndSelectWinner(widget.auctionId);
            if (context.mounted) {
              showSnack(context, 'Winner selected! All members notified 🏆');
              if (payoutId.isNotEmpty) context.push('/winner/${widget.auctionId}');
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    ));
  }
}

class _AuctionTab extends StatelessWidget {
  final String auctionId;
  final List bids;
  final double highest;
  final TextEditingController bidCtrl;
  final VoidCallback onBid;
  const _AuctionTab({required this.auctionId, required this.bids, required this.highest, required this.bidCtrl, required this.onBid});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(gradient: AppColors.cardGradient, child: Column(children: [
        const Text('Current Highest Bid', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Text(AppUtils.formatCurrency(highest), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
        Text('${bids.length} bids placed', style: const TextStyle(color: Colors.white60, fontSize: 13)),
      ])),
      const SizedBox(height: 16),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Place Your Bid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        TextFormField(
          controller: bidCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: 'Enter bid amount', prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primary), helperText: 'Min: ${AppUtils.formatCurrency(highest + 500)}'),
        ),
        const SizedBox(height: 12),
        Row(children: [highest + 500, highest + 1000, highest + 2000].map((amt) => Expanded(child: GestureDetector(
          onTap: () => bidCtrl.text = amt.toInt().toString(),
          child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
            child: Center(child: Text(AppUtils.formatCurrency(amt), style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)))),
        ))).toList()),
        const SizedBox(height: 14),
        GradientButton(label: 'Place Bid', onPressed: onBid, icon: Icons.gavel_rounded),
      ])),
      const SizedBox(height: 16),
      const Text('Live Bids', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      if (bids.isEmpty)
        const AppEmptyState(icon: Icons.gavel_outlined, title: 'No bids yet', subtitle: 'Be the first to bid!')
      else
        ...bids.map((b) => AppCard(padding: const EdgeInsets.all(12), child: Row(children: [
          CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(AppUtils.getInitials(b.userName), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
            Text(AppUtils.timeAgo(b.bidDateTime), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(AppUtils.formatCurrency(b.bidAmount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            if (b.isWinning) StatusBadge(label: 'Highest', color: AppColors.success),
          ]),
        ]))),
    ]);
  }
}

class _LotteryTab extends ConsumerWidget {
  final String auctionId;
  final dynamic auction;
  const _LotteryTab({required this.auctionId, required this.auction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider).valueOrNull?.uid ?? '';
    final isIn = (auction.lotteryParticipants as List).contains(uid);
    return ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(gradient: AppColors.primaryGradient, child: Column(children: [
        const Icon(Icons.casino_rounded, color: Colors.white, size: 40),
        const SizedBox(height: 12),
        const Text('Fair Lottery System', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Prize: ${AppUtils.formatCurrency(auction.totalFund)}', style: const TextStyle(color: AppColors.accent, fontSize: 22, fontWeight: FontWeight.w700)),
        Text('${(auction.lotteryParticipants as List).length} participants', style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ])),
      const SizedBox(height: 16),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('How It Works', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...['All members get 1 entry each', 'AI ensures completely random selection', 'Winner receives the full fund amount', 'Results are transparent and verifiable']
            .map((s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16), const SizedBox(width: 8),
              Expanded(child: Text(s, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
            ]))),
      ])),
      const SizedBox(height: 16),
      isIn
          ? AppCard(child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.how_to_vote_rounded, color: AppColors.success, size: 24)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('You\'re In!', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                Text('Your entry is registered', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              StatusBadge(label: 'Registered', color: AppColors.success),
            ]))
          : GradientButton(
              label: 'Join Lottery',
              onPressed: () async {
                await ref.read(auctionNotifierProvider.notifier).joinLottery(auctionId);
                if (context.mounted) showSnack(context, 'You\'re in the lottery! Good luck 🍀');
              },
              icon: Icons.how_to_vote_rounded,
            ),
    ]);
  }
}
