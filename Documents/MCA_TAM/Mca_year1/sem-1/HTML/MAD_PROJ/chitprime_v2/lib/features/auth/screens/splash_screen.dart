import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.7, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15), shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: const Icon(Icons.shield_rounded, size: 56, color: AppColors.accent),
                ),
                const SizedBox(height: 24),
                const Text('CHITPRIME', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2)),
                const SizedBox(height: 8),
                const Text('Smart Chit Fund Management', style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 48),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _badge(Icons.lock_rounded, 'Secure'),
                  _dot(), _badge(Icons.visibility_rounded, 'Transparent'),
                  _dot(), _badge(Icons.psychology_rounded, 'AI-Powered'),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: AppColors.accent), const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
  ]);
  Widget _dot() => const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('•', style: TextStyle(color: Colors.white38)));
}
