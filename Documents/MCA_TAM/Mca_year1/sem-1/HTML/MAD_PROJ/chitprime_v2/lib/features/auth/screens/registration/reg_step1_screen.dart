import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/aadhaar_registry.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../providers/auth_provider.dart';

class RegStep1Screen extends ConsumerStatefulWidget {
  const RegStep1Screen({super.key});

  @override
  ConsumerState<RegStep1Screen> createState() => _RegStep1ScreenState();
}

class _RegStep1ScreenState extends ConsumerState<RegStep1Screen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _picker = ImagePicker();

  Uint8List? _aadhaarImageBytes;
  String _aadhaarImageName = '';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _aadhaarCtrl.dispose();
    super.dispose();
  }

  String get _name => _nameCtrl.text.trim();
  String get _email => _emailCtrl.text.trim();
  String get _aadhaarNumber => AadhaarRegistry.digitsOnly(_aadhaarCtrl.text);

  bool get _isEmailValid =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email);
  bool get _hasValidAadhaar =>
      AadhaarRegistry.isValidFormat(_aadhaarNumber) &&
      AadhaarRegistry.matches(_name, _aadhaarNumber);

  Future<void> _pickAadhaarImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 35,
      maxWidth: 900,
      maxHeight: 900,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    if (bytes.lengthInBytes > 350000) {
      showSnack(
        context,
        'Choose a smaller Aadhaar image. Keep it under about 350 KB.',
        isError: true,
      );
      return;
    }

    setState(() {
      _aadhaarImageBytes = bytes;
      _aadhaarImageName = file.name;
    });
  }

  Future<void> _submit() async {
    if (_name.isEmpty) {
      showSnack(context, 'Enter your full name', isError: true);
      return;
    }
    if (_email.isEmpty || !_isEmailValid) {
      showSnack(context, 'Enter a valid email address', isError: true);
      return;
    }
    if (!AadhaarRegistry.isValidFormat(_aadhaarNumber)) {
      showSnack(context, 'Aadhaar number must be exactly 12 digits',
          isError: true);
      return;
    }
    if (!_hasValidAadhaar) {
      showSnack(context, 'Name and Aadhaar are not in the verified list',
          isError: true);
      return;
    }
    if (_aadhaarImageBytes == null) {
      showSnack(context, 'Upload your Aadhaar image for KYC review',
          isError: true);
      return;
    }

    final uid = ref.read(authStateProvider).valueOrNull?.uid ?? '';
    if (uid.isEmpty) {
      showSnack(context, 'Login again to continue registration',
          isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authNotifierProvider.notifier).completeRegistration(
            uid: uid,
            name: _name,
            email: _email,
            aadhaarNumber: _aadhaarNumber,
            aadhaarImageBytes: _aadhaarImageBytes,
            aadhaarFileName:
                _aadhaarImageName.isEmpty ? 'aadhaar.jpg' : _aadhaarImageName,
          );
      if (!mounted) return;
      setState(() => _loading = false);
      showSnack(
        context,
        'KYC submitted. Dashboard opened and admin review is now pending.',
      );
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showSnack(context, 'Could not submit KYC: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final phone = user?.phone ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile & KYC'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).logout();
            if (mounted) context.go('/login');
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 2 of 2',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Submit your Aadhaar KYC for admin review',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  phone.isEmpty
                      ? 'Your mobile number is already captured.'
                      : 'Phone number captured: +91 $phone',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Full name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _aadhaarCtrl,
            keyboardType: TextInputType.number,
            maxLength: 12,
            onChanged: (_) => setState(() {}),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: '12-digit Aadhaar number',
              prefixIcon: Icon(Icons.credit_card_rounded),
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          _validationBanner(),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload Aadhaar Image',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Upload a clear Aadhaar image so the admin can verify it from the Users tab.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                if (_aadhaarImageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _aadhaarImageBytes!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (_aadhaarImageBytes != null) const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickAadhaarImage,
                  icon: const Icon(Icons.upload_rounded),
                  label: Text(
                    _aadhaarImageBytes == null
                        ? 'Choose Aadhaar Image'
                        : 'Replace Aadhaar Image',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                if (_aadhaarImageName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _aadhaarImageName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Submit KYC',
            isLoading: _loading,
            onPressed: _submit,
            icon: Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }

  Widget _validationBanner() {
    if (_name.isEmpty && _aadhaarNumber.isEmpty) {
      return _statusCard(
        color: AppColors.primary,
        icon: Icons.info_outline_rounded,
        text:
            'Aadhaar will be checked instantly against the built-in approved registry.',
      );
    }

    if (!AadhaarRegistry.isValidFormat(_aadhaarNumber)) {
      return _statusCard(
        color: AppColors.warning,
        icon: Icons.edit_rounded,
        text: 'Enter a 12-digit Aadhaar number to validate it.',
      );
    }

    if (_name.isEmpty) {
      return _statusCard(
        color: AppColors.warning,
        icon: Icons.person_search_rounded,
        text: 'Enter the full name to match this Aadhaar number.',
      );
    }

    if (_hasValidAadhaar) {
      return _statusCard(
        color: AppColors.success,
        icon: Icons.verified_rounded,
        text: 'Aadhaar matched for $_name. You can upload the KYC image now.',
      );
    }

    return _statusCard(
      color: AppColors.error,
      icon: Icons.error_outline_rounded,
      text:
          'Invalid Aadhaar on spot check. This name and Aadhaar pair is not in the approved list.',
    );
  }

  Widget _statusCard({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
