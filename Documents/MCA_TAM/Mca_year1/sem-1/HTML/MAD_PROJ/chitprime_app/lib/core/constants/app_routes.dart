import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/groups/screens/groups_screen.dart';
import '../../features/groups/screens/group_detail_screen.dart';
import '../../features/payments/screens/payment_screen.dart';
import '../../features/payments/screens/payment_success_screen.dart';
import '../../features/auctions/screens/auction_screen.dart';
import '../../features/credit_score/screens/credit_score_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../admin_features/admin_auth/providers/admin_auth_provider.dart';
import '../../admin_features/admin_auth/screens/admin_login_screen.dart';
import '../../admin_features/admin_dashboard/screens/admin_main_screen.dart';

class AppRoutes {
  // User routes
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const groups = '/groups';
  static const groupDetail = '/groups/:id';
  static const payment = '/payment/:groupId';
  static const paymentSuccess = '/payment-success';
  static const auction = '/auction/:groupId';
  static const creditScore = '/credit-score';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';

  // Admin routes
  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';

  static GoRouter userRouter(AuthProvider auth) => GoRouter(
        initialLocation: splash,
        redirect: (context, state) {
          final isAuth = auth.isAuthenticated;
          final loc = state.matchedLocation;
          final isAuthRoute = loc == login ||
              loc == otp ||
              loc == register ||
              loc == splash;
          if (!isAuth && !isAuthRoute) return login;
          if (isAuth && (loc == login || loc == register || loc == splash)) {
            return dashboard;
          }
          return null;
        },
        routes: [
          GoRoute(path: splash, builder: (_, __) => const SplashScreen()),
          GoRoute(path: login, builder: (_, __) => const LoginScreen()),
          GoRoute(
            path: otp,
            builder: (_, state) =>
                OtpScreen(phone: state.extra as String? ?? ''),
          ),
          GoRoute(path: register, builder: (_, __) => const RegisterScreen()),
          GoRoute(path: dashboard, builder: (_, __) => const DashboardScreen()),
          GoRoute(path: groups, builder: (_, __) => const GroupsScreen()),
          GoRoute(
            path: groupDetail,
            builder: (_, state) =>
                GroupDetailScreen(groupId: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: payment,
            builder: (_, state) =>
                PaymentScreen(groupId: state.pathParameters['groupId'] ?? ''),
          ),
          GoRoute(
            path: paymentSuccess,
            builder: (_, state) =>
                PaymentSuccessScreen(data: state.extra as Map<String, dynamic>?),
          ),
          GoRoute(
            path: auction,
            builder: (_, state) =>
                AuctionScreen(groupId: state.pathParameters['groupId'] ?? ''),
          ),
          GoRoute(
            path: creditScore,
            builder: (_, __) => const CreditScoreScreen(),
          ),
          GoRoute(
            path: notifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(path: profile, builder: (_, __) => const ProfileScreen()),
          GoRoute(
            path: editProfile,
            builder: (_, __) => const EditProfileScreen(),
          ),
        ],
      );

  static GoRouter adminRouter(AdminAuthProvider auth) => GoRouter(
        initialLocation: adminLogin,
        redirect: (context, state) {
          final isAuth = auth.isAuthenticated;
          if (!isAuth && state.matchedLocation != adminLogin) return adminLogin;
          if (isAuth && state.matchedLocation == adminLogin) {
            return adminDashboard;
          }
          return null;
        },
        routes: [
          GoRoute(
            path: adminLogin,
            builder: (_, __) => const AdminLoginScreen(),
          ),
          GoRoute(
            path: adminDashboard,
            builder: (_, __) => const AdminMainScreen(),
          ),
        ],
      );
}
