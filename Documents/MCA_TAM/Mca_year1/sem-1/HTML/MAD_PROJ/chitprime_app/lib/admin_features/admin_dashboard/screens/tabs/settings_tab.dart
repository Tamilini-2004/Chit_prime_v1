import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../settings/providers/settings_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPlatformSettings(context, provider),
        const SizedBox(height: 16),
        _buildSecuritySettings(context, provider),
        const SizedBox(height: 16),
        _buildAdminManagement(),
        const SizedBox(height: 16),
        _buildCompliance(),
        const SizedBox(height: 16),
        GradientButton(
          label: 'Save All Settings',
          onPressed: () => provider.saveSettings(),
          icon: Icons.save_rounded,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPlatformSettings(
      BuildContext context, SettingsProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Settings',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _sliderSetting(
            'Commission Rate',
            '${provider.commissionRate.toStringAsFixed(1)}%',
            provider.commissionRate,
            1.0,
            10.0,
            (v) => provider.updateCommission(v),
          ),
          _sliderSetting(
            'GST Rate',
            '${provider.gstRate.toStringAsFixed(1)}%',
            provider.gstRate,
            0.0,
            28.0,
            (v) => provider.updateGst(v),
          ),
          _sliderSetting(
            'Min Group Size',
            '${provider.minGroupSize} members',
            provider.minGroupSize.toDouble(),
            5.0,
            20.0,
            (v) => provider.updateMinGroupSize(v.toInt()),
          ),
          _sliderSetting(
            'Max Group Size',
            '${provider.maxGroupSize} members',
            provider.maxGroupSize.toDouble(),
            20.0,
            100.0,
            (v) => provider.updateMaxGroupSize(v.toInt()),
          ),
          _sliderSetting(
            'Auction Duration',
            '${provider.auctionDurationHours} hours',
            provider.auctionDurationHours.toDouble(),
            6.0,
            72.0,
            (v) {},
          ),
        ],
      ),
    );
  }

  Widget _sliderSetting(String label, String value, double current, double min,
      double max, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
        Slider(
          value: current.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSecuritySettings(
      BuildContext context, SettingsProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security Settings',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _switchTile(
            'Enforce 2FA for Admins',
            Icons.security_rounded,
            AppColors.primary,
            provider.enforce2FA,
            (v) => provider.toggle2FA(v),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.timer_rounded,
                  color: AppColors.secondary, size: 20),
            ),
            title: const Text('Session Timeout',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            trailing: Text('${provider.sessionTimeoutMinutes} min',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
          const Divider(height: 1),
          ...[
            ('Password Policies', Icons.password_rounded, AppColors.accent),
            ('API Access Controls', Icons.api_rounded, AppColors.secondary),
            ('Audit Logs', Icons.history_rounded, AppColors.textSecondary),
          ].map((e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: e.$3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(e.$2, color: e.$3, size: 20),
                ),
                title: Text(e.$1,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textSecondary),
                onTap: () {},
              )),
        ],
      ),
    );
  }

  Widget _switchTile(String label, IconData icon, Color color, bool value,
      ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: color),
      ],
    );
  }

  Widget _buildAdminManagement() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin User Management',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...[
            ('Create Admin Account', Icons.person_add_rounded, AppColors.primary),
            ('Manage Roles & Permissions', Icons.manage_accounts_rounded, AppColors.secondary),
            ('View Admin Activity Logs', Icons.history_rounded, AppColors.accent),
          ].map((e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: e.$3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(e.$2, color: e.$3, size: 20),
                ),
                title: Text(e.$1,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textSecondary),
                onTap: () {},
              )),
        ],
      ),
    );
  }

  Widget _buildCompliance() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Compliance & Legal',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...[
            ('Terms of Service', Icons.description_rounded, AppColors.primary),
            ('Privacy Policy', Icons.privacy_tip_rounded, AppColors.secondary),
            ('KYC Requirements', Icons.verified_user_rounded, AppColors.success),
            ('Regulatory Settings', Icons.gavel_rounded, AppColors.accent),
            ('Audit Logs', Icons.fact_check_rounded, AppColors.textSecondary),
          ].map((e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: e.$3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(e.$2, color: e.$3, size: 20),
                ),
                title: Text(e.$1,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textSecondary),
                onTap: () {},
              )),
        ],
      ),
    );
  }
}
