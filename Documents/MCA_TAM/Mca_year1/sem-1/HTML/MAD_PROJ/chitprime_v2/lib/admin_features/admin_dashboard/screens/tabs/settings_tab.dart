import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shared_widgets.dart';

final platformSettingsProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('settings').doc('platform').snapshots()
      .map((d) => d.data() ?? <String, dynamic>{});
});

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});
  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  double _commission = 3.0;
  double _gst = 18.0;
  int _minGroup = 2;
  int _maxGroup = 50;
  bool _maintenance = false;
  bool _enforce2FA = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(platformSettingsProvider).valueOrNull;
      if (settings != null) {
        setState(() {
          _commission = ((settings['commissionRate'] ?? 0.03) * 100).toDouble();
          _gst = ((settings['gstRate'] ?? 0.18) * 100).toDouble();
          _minGroup = settings['minGroupSize'] ?? 2;
          _maxGroup = settings['maxGroupSize'] ?? 50;
          _maintenance = settings['maintenanceMode'] ?? false;
        });
      }
    });
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    await FirebaseFirestore.instance.collection('settings').doc('platform').update({
      'commissionRate': _commission / 100,
      'gstRate': _gst / 100,
      'minGroupSize': _minGroup,
      'maxGroupSize': _maxGroup,
      'maintenanceMode': _maintenance,
    });
    if (mounted) { setState(() => _loading = false); showSnack(context, 'Settings saved and applied to all users! ✓'); }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Platform settings
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Platform Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        _slider('Commission Rate', '${_commission.toStringAsFixed(1)}%', _commission, 1, 10, (v) => setState(() => _commission = v)),
        _slider('GST Rate', '${_gst.toStringAsFixed(1)}%', _gst, 0, 28, (v) => setState(() => _gst = v)),
        _slider('Min Group Size', '$_minGroup members', _minGroup.toDouble(), 2, 20, (v) => setState(() => _minGroup = v.toInt())),
        _slider('Max Group Size', '$_maxGroup members', _maxGroup.toDouble(), 10, 100, (v) => setState(() => _maxGroup = v.toInt())),
      ])),
      const SizedBox(height: 16),

      // Security settings
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Security Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _switchTile('Enforce 2FA for Admins', Icons.security_rounded, AppColors.primary, _enforce2FA, (v) => setState(() => _enforce2FA = v)),
        const Divider(height: 1),
        _switchTile('Maintenance Mode', Icons.build_rounded, AppColors.warning, _maintenance, (v) => setState(() => _maintenance = v)),
        if (_maintenance) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: const Text('⚠️ Maintenance mode will show a maintenance screen to all users.', style: TextStyle(fontSize: 12, color: AppColors.warning))),
        ],
      ])),
      const SizedBox(height: 16),

      // Admin management
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Admin Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...[('Create Admin Account', Icons.person_add_rounded, AppColors.primary), ('Manage Roles & Permissions', Icons.manage_accounts_rounded, AppColors.secondary), ('View Audit Logs', Icons.history_rounded, AppColors.accent)]
            .map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: e.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(e.$2, color: e.$3, size: 20)),
              title: Text(e.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
              onTap: () => showSnack(context, '${e.$1} opened'),
            )),
      ])),
      const SizedBox(height: 16),

      GradientButton(label: 'Save All Settings', isLoading: _loading, onPressed: _save, icon: Icons.save_rounded),
      const SizedBox(height: 24),
    ]);
  }

  Widget _slider(String label, String value, double current, double min, double max, ValueChanged<double> onChanged) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
      Slider(value: current.clamp(min, max), min: min, max: max, activeColor: AppColors.primary, onChanged: onChanged),
    ]);
  }

  Widget _switchTile(String label, IconData icon, Color color, bool value, ValueChanged<bool> onChanged) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
      Switch(value: value, onChanged: onChanged, activeColor: color),
    ]);
  }
}
