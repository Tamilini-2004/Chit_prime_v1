import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../features/auth/providers/auth_provider.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailCtrl = TextEditingController(text: 'test@admin.com');
  final _passCtrl = TextEditingController(text: 'admin123');
  bool _obscure = true, _loading = false;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    setState(() => _loading = true);
    final error = await ref.read(authNotifierProvider.notifier).signInAdmin(
      _emailCtrl.text.trim(), _passCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) showSnack(context, error, isError: true);
    // Router redirect handles navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(child: Column(children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/'),
            ),
          ),
          const SizedBox(height: 10),
          _header(),
          const SizedBox(height: 32),
          Expanded(child: _card()),
        ])),
      ),
    );
  }

  Widget _header() => Column(children: [
    Container(
      width: 80, height: 80,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
      child: const Icon(Icons.admin_panel_settings_rounded, size: 44, color: AppColors.accent),
    ),
    const SizedBox(height: 16),
    const Text('CHITPRIME Admin', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
    const Text('Secure Admin Portal', style: TextStyle(fontSize: 13, color: Colors.white70)),
  ]);

  Widget _card() => Container(
    decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Admin Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      const Text('Enter your admin credentials', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      const SizedBox(height: 28),
      TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(hintText: 'Admin Email', prefixIcon: Icon(Icons.email_outlined)),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passCtrl,
        obscureText: _obscure,
        decoration: InputDecoration(
          hintText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
      const SizedBox(height: 24),
      GradientButton(label: 'Admin Login', isLoading: _loading, onPressed: _login, icon: Icons.login_rounded),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.warning.withOpacity(0.3))),
        child: const Row(children: [
          Icon(Icons.security_rounded, size: 16, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(child: Text('Admin access only. All actions are logged.', style: TextStyle(fontSize: 12, color: AppColors.warning))),
        ]),
      ),
      const Spacer(),
      const Center(child: Text('Demo: test@admin.com / admin123', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
    ]),
  );
}
