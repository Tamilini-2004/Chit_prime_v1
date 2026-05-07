import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String role;
  const LoginScreen({super.key, this.role = 'member'});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 10) {
      showSnack(context, 'Enter a valid 10-digit mobile number', isError: true);
      return;
    }

    setState(() => _loading = true);
    final error = await ref.read(authNotifierProvider.notifier).signInMember(phone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) showSnack(context, error, isError: true);
    // Router redirect handles navigation automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(child: Column(children: [
          // Back button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/'),
            ),
          ),
          const SizedBox(height: 20),
          _header(),
          const SizedBox(height: 32),
          Expanded(child: _card()),
        ])),
      ),
    );
  }

  Widget _header() => Column(children: [
    Container(
      width: 72, height: 72,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
      child: const Icon(Icons.person_rounded, size: 40, color: AppColors.accent),
    ),
    const SizedBox(height: 16),
    const Text('CHITPRIME', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5)),
    const Text('Member / Foreman Login', style: TextStyle(fontSize: 13, color: Colors.white70)),
  ]);

  Widget _card() => Container(
    decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Continue with Mobile Number', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      const Text('New users will complete name, email, Aadhaar and KYC upload on the next screen.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      const SizedBox(height: 28),
      TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: '10-digit mobile number',
          counterText: '',
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.phone_android_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('+91', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: AppColors.divider),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 20),
      GradientButton(label: 'Continue', isLoading: _loading, onPressed: _login, icon: Icons.arrow_forward_rounded),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(child: Text('Phone login stays in test mode, but the number is now required before KYC can continue.', style: TextStyle(fontSize: 12, color: AppColors.primary))),
        ]),
      ),
      const Spacer(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _badge(Icons.lock_rounded, 'Secure'),
        const SizedBox(width: 20),
        _badge(Icons.verified_rounded, 'Verified'),
        const SizedBox(width: 20),
        _badge(Icons.psychology_rounded, 'AI-Powered'),
      ]),
    ]),
  );

  Widget _badge(IconData icon, String label) => Column(children: [
    Icon(icon, size: 20, color: AppColors.primary),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
  ]);
}
