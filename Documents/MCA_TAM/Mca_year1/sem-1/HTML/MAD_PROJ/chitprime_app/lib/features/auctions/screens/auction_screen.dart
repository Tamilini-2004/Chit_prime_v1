import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/auction_provider.dart';

class AuctionScreen extends StatefulWidget {
  final String groupId;
  const AuctionScreen({super.key, required this.groupId});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuctionProvider>().loadAuction(widget.groupId);
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final auction = context.read<AuctionProvider>().currentAuction;
      if (auction != null && mounted) {
        setState(() => _remaining = auction.timeRemaining);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuctionProvider>();
    final auction = provider.currentAuction;

    return Scaffold(
      body: auction == null && provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : auction == null
              ? const AppEmptyState(
                  icon: Icons.gavel_rounded,
                  title: 'No live auction',
                  subtitle: 'Check back when the next auction starts',
                )
              : NestedScrollView(
                  headerSliverBuilder: (_, __) => [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 180,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient),
                          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      auction.groupName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.circle,
                                            size: 8, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('LIVE',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.timer_rounded,
                                      size: 14, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppUtils.formatCountdown(_remaining),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Fund: ${AppUtils.formatCurrency(auction.totalFund)}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      bottom: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        indicatorColor: AppColors.accent,
                        tabs: const [
                          Tab(text: 'Auction'),
                          Tab(text: 'Lottery'),
                        ],
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _AuctionTab(auction: auction),
                      _LotteryTab(auction: auction),
                    ],
                  ),
                ),
    );
  }
}

class _AuctionTab extends StatefulWidget {
  final dynamic auction;
  const _AuctionTab({required this.auction});

  @override
  State<_AuctionTab> createState() => _AuctionTabState();
}

class _AuctionTabState extends State<_AuctionTab> {
  final _bidCtrl = TextEditingController();

  @override
  void dispose() {
    _bidCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auction = widget.auction;
    final bids = auction.bids as List;
    final highestBid = auction.highestBid as double;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          gradient: AppColors.cardGradient,
          child: Column(
            children: [
              const Text('Current Highest Bid',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                AppUtils.formatCurrency(highestBid),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${bids.length} bids placed',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Place Your Bid',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bidCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Enter bid amount',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded,
                      color: AppColors.primary),
                  helperText:
                      'Min bid: ${AppUtils.formatCurrency(highestBid + 1000)}',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _quickBid(highestBid + 1000),
                  const SizedBox(width: 8),
                  _quickBid(highestBid + 2000),
                  const SizedBox(width: 8),
                  _quickBid(highestBid + 5000),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<AuctionProvider>(
                builder: (_, provider, __) => GradientButton(
                  label: 'Place Bid',
                  isLoading: provider.isPlacingBid,
                  onPressed: () => _placeBid(context, provider),
                  icon: Icons.gavel_rounded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Live Bids',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 10),
        ...bids.reversed.map((b) => _bidItem(b)),
      ],
    );
  }

  Widget _quickBid(double amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _bidCtrl.text = amount.toInt().toString();
          // Show feedback
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              AppUtils.formatCurrency(amount),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bidItem(dynamic b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              AppUtils.getInitials(b.userName),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    )),
                Text(AppUtils.timeAgo(b.bidTime),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppUtils.formatCurrency(b.bidAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              if (b.isWinning)
                StatusBadge(label: 'Highest', color: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _placeBid(BuildContext context, AuctionProvider provider) async {
    final amount = double.tryParse(_bidCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid bid amount'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final highestBid = widget.auction.highestBid as double;
    if (amount <= highestBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid must be higher than current highest: ${AppUtils.formatCurrency(highestBid)}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final success = await provider.placeBid(
      auctionId: widget.auction.auctionId,
      userId: user.userId,
      userName: user.fullName,
      amount: amount,
    );
    if (context.mounted) {
      _bidCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(success ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(success ? 'Bid of ${AppUtils.formatCurrency(amount)} placed successfully!' : 'Failed to place bid'),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

class _LotteryTab extends StatelessWidget {
  final dynamic auction;
  const _LotteryTab({required this.auction});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          gradient: AppColors.primaryGradient,
          child: Column(
            children: [
              const Icon(Icons.casino_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              const Text('Fair Lottery System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 8),
              Text(
                'Prize: ${AppUtils.formatCurrency(auction.totalFund as double)}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How Lottery Works',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 12),
              ...[
                'All members get 1 entry each',
                'AI ensures completely random selection',
                'Winner receives the full fund amount',
                'Results are transparent and verifiable',
              ].map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.how_to_vote_rounded,
                    color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Entry',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        )),
                    Text('1 entry registered',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StatusBadge(label: 'Registered', color: AppColors.success),
            ],
          ),
        ),
      ],
    );
  }
}
