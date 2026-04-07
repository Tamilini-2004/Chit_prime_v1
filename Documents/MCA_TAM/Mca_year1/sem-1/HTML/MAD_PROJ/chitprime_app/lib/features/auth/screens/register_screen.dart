import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _confirmAccountCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _aadhaarCtrl, _panCtrl,
      _accountCtrl, _confirmAccountCtrl, _ifscCtrl,
      _bankNameCtrl, _accountHolderCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (_formKeys[_step].currentState!.validate()) {
      if (_step < 2) {
        setState(() => _step++);
      } else {
        _submit();
      }
    }
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.register({
      'fullName': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'aadhaar': _aadhaarCtrl.text.trim(),
      'pan': _panCtrl.text.trim().toUpperCase(),
      'bankAccount': _accountCtrl.text.trim(),
      'ifsc': _ifscCtrl.text.trim().toUpperCase(),
      'bankName': _bankNameCtrl.text.trim(),
    });
    if (success && mounted) context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (_step > 0)
            GestureDetector(
              onTap: () => setState(() => _step--),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            )
          else
            GestureDetector(
              onTap: () => context.go(AppRoutes.login),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stepTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Step ${_step + 1} of 3',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildProgressDots(),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.only(left: 6),
          width: i == _step ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i <= _step ? AppColors.accent : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return AppStrings.personalInfo;
      case 1:
        return AppStrings.identityVerification;
      default:
        return AppStrings.bankDetails;
    }
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: [_step0(), _step1(), _step2()][_step],
      ),
    );
  }

  Widget _step0() {
    return Form(
      key: _formKeys[0],
      child: Column(
        children: [
          AppTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameCtrl,
            prefix: const Icon(Icons.person_outline_rounded, size: 20),
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? AppStrings.requiredField : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Mobile Number',
            hint: context.read<AuthProvider>().pendingPhone ?? '',
            readOnly: true,
            prefix: const Icon(Icons.phone_android_rounded, size: 20),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Email Address (Optional)',
            hint: 'Enter your email',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefix: const Icon(Icons.email_outlined, size: 20),
            validator: (v) {
              if (v == null || v.isEmpty) return null;
              return AppUtils.isValidEmail(v) ? null : 'Invalid email address';
            },
          ),
          const SizedBox(height: 32),
          GradientButton(label: 'Next', onPressed: _next, icon: Icons.arrow_forward_rounded),
        ],
      ),
    );
  }

  Widget _step1() {
    return Form(
      key: _formKeys[1],
      child: Column(
        children: [
          _docUploadCard('Aadhaar Card', Icons.credit_card_rounded),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Aadhaar Number',
            hint: 'Enter 12-digit Aadhaar number',
            controller: _aadhaarCtrl,
            keyboardType: TextInputType.number,
            maxLength: 12,
            prefix: const Icon(Icons.badge_outlined, size: 20),
            validator: (v) => AppUtils.isValidAadhaar(v ?? '')
                ? null
                : AppStrings.invalidAadhaar,
          ),
          const SizedBox(height: 16),
          _docUploadCard('PAN Card', Icons.article_outlined),
          const SizedBox(height: 16),
          AppTextField(
            label: 'PAN Number',
            hint: 'Enter PAN (e.g. ABCDE1234F)',
            controller: _panCtrl,
            maxLength: 10,
            prefix: const Icon(Icons.credit_card_outlined, size: 20),
            validator: (v) => AppUtils.isValidPan(v ?? '')
                ? null
                : AppStrings.invalidPan,
          ),
          const SizedBox(height: 32),
          GradientButton(label: 'Next', onPressed: _next, icon: Icons.arrow_forward_rounded),
        ],
      ),
    );
  }

  Widget _step2() {
    return Form(
      key: _formKeys[2],
      child: Column(
        children: [
          AppTextField(
            label: 'Bank Account Number',
            hint: 'Enter account number',
            controller: _accountCtrl,
            keyboardType: TextInputType.number,
            maxLength: 18,
            prefix: const Icon(Icons.account_balance_outlined, size: 20),
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? AppStrings.requiredField : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Confirm Account Number',
            hint: 'Re-enter account number',
            controller: _confirmAccountCtrl,
            keyboardType: TextInputType.number,
            maxLength: 18,
            prefix: const Icon(Icons.account_balance_outlined, size: 20),
            validator: (v) => v != _accountCtrl.text
                ? AppStrings.accountMismatch
                : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'IFSC Code',
            hint: 'Enter IFSC code',
            controller: _ifscCtrl,
            maxLength: 11,
            prefix: const Icon(Icons.code_rounded, size: 20),
            validator: (v) => AppUtils.isValidIfsc(v ?? '')
                ? null
                : AppStrings.invalidIfsc,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Bank Name',
            hint: 'Enter bank name',
            controller: _bankNameCtrl,
            prefix: const Icon(Icons.business_rounded, size: 20),
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? AppStrings.requiredField : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Account Holder Name',
            hint: 'Enter account holder name',
            controller: _accountHolderCtrl,
            prefix: const Icon(Icons.person_outline_rounded, size: 20),
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? AppStrings.requiredField : null,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, size: 16, color: AppColors.success),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All data encrypted and secure',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Consumer<AuthProvider>(
            builder: (_, auth, __) => GradientButton(
              label: AppStrings.completeRegistration,
              isLoading: auth.status == AuthStatus.loading,
              onPressed: _next,
              icon: Icons.check_circle_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _docUploadCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Tap to upload (Front & Back)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.upload_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
