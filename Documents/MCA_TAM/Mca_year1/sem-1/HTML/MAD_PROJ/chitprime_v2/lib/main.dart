import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_router.dart';
import 'data/mock/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Seed demo data on first launch
  await SeedData.seedIfEmpty();

  runApp(const ProviderScope(child: ChitPrimeApp()));
}

class ChitPrimeApp extends ConsumerWidget {
  const ChitPrimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'CHITPRIME',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        // Global error boundary
        ErrorWidget.builder = (details) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                const Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(details.exceptionAsString(), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => router.go('/'),
                  child: const Text('Go to Home'),
                ),
              ]),
            ),
          ),
        );
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
