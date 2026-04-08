import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/registration/reg_step1_screen.dart';
import '../../features/auth/screens/registration/reg_step2_screen.dart';
import '../../features/auth/screens/registration/reg_step3_screen.dart';
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
import '../../admin_features/admin_auth/screens/admin_login_screen.dart';
import '../../admin_features/admin_dashboard/screens/admin_shell_screen.dart';

// User router
final userRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.valueOrNull != null;
      final loc = state.matchedLocation;
      final authRoutes = ['/', '/login', '/otp', '/register/1', '/register/2', '/register/3'];
      if (!isAuth && !authRoutes.contains(loc)) return '/login';
      if (isAuth && (loc == '/login' || loc == '/')) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (_, s) => OtpScreen(phone: s.extra as String? ?? '')),
      GoRoute(path: '/register/1', builder: (_, __) => const RegStep1Screen()),
      GoRoute(path: '/register/2', builder: (_, __) => const RegStep2Screen()),
      GoRoute(path: '/register/3', builder: (_, __) => const RegStep3Screen()),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/groups', builder: (_, __) => const GroupsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/groups/create', builder: (_, __) => const CreateGroupScreen()),
      GoRoute(path: '/groups/:id', builder: (_, s) => GroupDetailsScreen(groupId: s.pathParameters['id']!)),
      GoRoute(path: '/payment/:groupId', builder: (_, s) => PaymentScreen(groupId: s.pathParameters['groupId']!)),
      GoRoute(path: '/payment/success', builder: (_, s) => PaymentSuccessScreen(data: s.extra as Map<String, dynamic>?)),
      GoRoute(path: '/auction/:auctionId', builder: (_, s) => AuctionScreen(auctionId: s.pathParameters['auctionId']!)),
      GoRoute(path: '/winner/:auctionId', builder: (_, s) => WinnerScreen(auctionId: s.pathParameters['auctionId']!)),
      GoRoute(path: '/escrow/:payoutId', builder: (_, s) => EscrowPayoutScreen(payoutId: s.pathParameters['payoutId']!)),
      GoRoute(path: '/credit-score', builder: (_, __) => const CreditScoreScreen()),
      GoRoute(path: '/chat/:conversationId', builder: (_, s) => ChatScreen(conversationId: s.pathParameters['conversationId']!)),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
    ],
  );
});

// Admin router
final adminRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/admin',
    redirect: (context, state) {
      final isAuth = authState.valueOrNull != null;
      if (!isAuth && state.matchedLocation != '/admin') return '/admin';
      if (isAuth && state.matchedLocation == '/admin') return '/admin/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/admin', builder: (_, __) => const AdminLoginScreen()),
      GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminShellScreen()),
      GoRoute(path: '/admin/chat/:id', builder: (_, s) => ChatScreen(conversationId: s.pathParameters['id']!)),
    ],
  );
});

// Shell with bottom nav
class HomeShell extends StatefulWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _tabs = ['/dashboard', '/groups', '/notifications', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          context.go(_tabs[i]);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group_rounded), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
