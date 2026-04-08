import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
// Auth
import '../../features/auth/screens/role_select_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/registration/reg_step1_screen.dart';
import '../../features/auth/screens/registration/reg_step2_screen.dart';
import '../../features/auth/screens/registration/reg_step3_screen.dart';
// Member screens
import '../../features/dashboard/screens/home_screen.dart';
import '../../features/groups/screens/groups_screen.dart';
import '../../features/groups/screens/create_group_screen.dart';
import '../../features/groups/screens/group_details_screen.dart';
import '../../features/contributions/screens/payment_screen.dart';
import '../../features/contributions/screens/payment_success_screen.dart';
import '../../features/auction/screens/auction_screen.dart';
import '../../features/auction/screens/winner_screen.dart';
import '../../features/escrow/screens/escrow_payout_screen.dart';
import '../../features/credit_score/screens/credit_score_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
// Admin screens
import '../../admin_features/admin_auth/screens/admin_login_screen.dart';
import '../../admin_features/admin_dashboard/screens/admin_shell_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final userAsync = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      final isLoggedIn = authAsync.valueOrNull != null;
      final user = userAsync.valueOrNull;
      final loc = state.matchedLocation;

      // Not logged in — only allow auth routes
      if (!isLoggedIn) {
        if (loc == '/' || loc == '/login' || loc == '/admin/login' ||
            loc.startsWith('/register')) return null;
        return '/';
      }

      // Logged in — redirect from root/login to correct dashboard
      if (loc == '/' || loc == '/login' || loc == '/admin/login') {
        final role = user?.role ?? 'member';
        if (role == 'super_admin' || role == 'admin') return '/admin/dashboard';
        return '/dashboard';
      }

      // Admin trying to access member routes
      final role = user?.role ?? 'member';
      if ((role == 'super_admin' || role == 'admin') &&
          !loc.startsWith('/admin') && !loc.startsWith('/chat')) {
        return '/admin/dashboard';
      }

      return null;
    },
    routes: [
      // Role selector / splash
      GoRoute(path: '/', builder: (_, __) => const RoleSelectScreen()),
      GoRoute(path: '/login', builder: (_, s) => LoginScreen(role: s.extra as String? ?? 'member')),
      GoRoute(path: '/admin/login', builder: (_, __) => const AdminLoginScreen()),
      GoRoute(path: '/register/1', builder: (_, __) => const RegStep1Screen()),
      GoRoute(path: '/register/2', builder: (_, __) => const RegStep2Screen()),
      GoRoute(path: '/register/3', builder: (_, __) => const RegStep3Screen()),

      // Member shell with bottom nav
      ShellRoute(
        builder: (_, __, child) => MemberShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/groups', builder: (_, __) => const GroupsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Member detail routes
      GoRoute(path: '/groups/create', builder: (_, __) => const CreateGroupScreen()),
      GoRoute(path: '/groups/:id', builder: (_, s) => GroupDetailsScreen(groupId: s.pathParameters['id']!)),
      GoRoute(path: '/payment/:groupId', builder: (_, s) => PaymentScreen(groupId: s.pathParameters['groupId']!)),
      GoRoute(path: '/payment/success', builder: (_, s) => PaymentSuccessScreen(data: s.extra as Map<String, dynamic>?)),
      GoRoute(path: '/auction/:auctionId', builder: (_, s) => AuctionScreen(auctionId: s.pathParameters['auctionId']!)),
      GoRoute(path: '/winner/:auctionId', builder: (_, s) => WinnerScreen(auctionId: s.pathParameters['auctionId']!)),
      GoRoute(path: '/escrow/:payoutId', builder: (_, s) => EscrowPayoutScreen(payoutId: s.pathParameters['payoutId']!)),
      GoRoute(path: '/credit-score', builder: (_, __) => const CreditScoreScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/chat/:id', builder: (_, s) => ChatScreen(conversationId: s.pathParameters['id']!)),

      // Admin routes
      GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminShellScreen()),
      GoRoute(path: '/admin/chat/:id', builder: (_, s) => ChatScreen(conversationId: s.pathParameters['id']!)),
    ],
  );
});

// Notifier to refresh router on auth change
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
}

// Member bottom nav shell
class MemberShell extends ConsumerStatefulWidget {
  final Widget child;
  const MemberShell({super.key, required this.child});
  @override
  ConsumerState<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends ConsumerState<MemberShell> {
  int _index = 0;
  final _tabs = ['/dashboard', '/groups', '/notifications', '/profile'];

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) { setState(() => _index = i); context.go(_tabs[i]); },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group_rounded), label: 'Groups'),
          BottomNavigationBarItem(
            icon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.notifications_outlined)),
            activeIcon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.notifications_rounded)),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
