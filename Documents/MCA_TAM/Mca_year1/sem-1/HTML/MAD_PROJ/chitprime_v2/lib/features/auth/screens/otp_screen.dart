import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

class OtpScreen extends StatelessWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    // In test build, auto-navigate to dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/dashboard'));
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
