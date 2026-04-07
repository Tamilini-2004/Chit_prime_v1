import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/group_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'admin_features/admin_auth/providers/admin_auth_provider.dart';
import 'admin_features/admin_dashboard/providers/admin_dashboard_provider.dart';
import 'admin_features/user_management/providers/user_management_provider.dart';
import 'admin_features/group_management/providers/group_management_provider.dart';
import 'admin_features/fraud_detection/providers/fraud_provider.dart';
import 'admin_features/transactions/providers/transaction_provider.dart';
import 'admin_features/reports/providers/reports_provider.dart';
import 'admin_features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ChitPrimeAdminApp());
}

class ChitPrimeAdminApp extends StatelessWidget {
  const ChitPrimeAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => GroupRepository()),
        Provider(create: (_) => PaymentRepository()),
        ChangeNotifierProvider(
          create: (ctx) => AdminAuthProvider(ctx.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(
          create: (ctx) =>
              GroupManagementProvider(ctx.read<GroupRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => FraudProvider()),
        ChangeNotifierProvider(
          create: (ctx) =>
              TransactionProvider(ctx.read<PaymentRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<AdminAuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp.router(
            title: 'CHITPRIME Admin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRoutes.adminRouter(auth),
          );
        },
      ),
    );
  }
}
