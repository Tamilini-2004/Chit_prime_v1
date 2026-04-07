import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/group_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/auction_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/groups/providers/group_provider.dart';
import 'features/payments/providers/payment_provider.dart';
import 'features/auctions/providers/auction_provider.dart';
import 'features/credit_score/providers/credit_score_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/profile/providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ChitPrimeApp());
}

class ChitPrimeApp extends StatelessWidget {
  const ChitPrimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => GroupRepository()),
        Provider(create: (_) => PaymentRepository()),
        Provider(create: (_) => AuctionRepository()),
        Provider(create: (_) => NotificationRepository()),
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(ctx.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GroupProvider(ctx.read<GroupRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PaymentProvider(ctx.read<PaymentRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuctionProvider(ctx.read<AuctionRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => CreditScoreProvider()),
        ChangeNotifierProvider(
          create: (ctx) =>
              NotificationProvider(ctx.read<NotificationRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp.router(
            title: 'CHITPRIME',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRoutes.userRouter(auth),
          );
        },
      ),
    );
  }
}
