import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                // Logo
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: const Icon(Icons.shield_rounded, size: 56, color: AppColors.accent),
                ),
                const SizedBox(height: 24),
                const Text('CHITPRIME', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2)),
                const SizedBox(height: 8),
                const Text('Smart Chit Fund Management', style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _badge(Icons.lock_rounded, 'Secure'),
                  const SizedBox(width: 16),
                  _badge(Icons.visibility_rounded, 'Transparent'),
                  const SizedBox(width: 16),
                  _badge(Icons.psychology_rounded, 'AI-Powered'),
                ]),
                const Spacer(),
                // Role selection
                const Text('Choose your role to continue', style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                _roleCard(
                  context,
                  icon: Icons.person_rounded,
                  title: 'Member / Foreman',
                  subtitle: 'Join groups, pay contributions, bid in auctions',
                  color: Colors.white,
                  textColor: AppColors.primary,
                  onTap: () => context.push('/login', extra: 'member'),
                ),
                const SizedBox(height: 16),
                _roleCard(
                  context,
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin',
                  subtitle: 'Manage platform, users, groups & fraud detection',
                  color: AppColors.accent,
                  textColor: Colors.white,
                  onTap: () => context.push('/admin/login'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, {
    required IconData icon, required String title, required String subtitle,
    required Color color, required Color textColor, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(color == Colors.white ? 1 : 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: textColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.7))),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, color: textColor.withOpacity(0.5), size: 16),
        ]),
      ),
    );
  }

  Widget _badge(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: AppColors.accent),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
  ]);
}
