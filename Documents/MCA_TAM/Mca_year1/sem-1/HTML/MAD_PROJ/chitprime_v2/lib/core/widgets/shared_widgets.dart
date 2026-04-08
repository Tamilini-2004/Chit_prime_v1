import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

// ── Gradient Button ──────────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient gradient;
  final IconData? icon;
  final double height;

  const GradientButton({
    super.key, required this.label, this.onPressed, this.isLoading = false,
    this.gradient = AppColors.primaryGradient, this.icon, this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity, height: height,
        decoration: BoxDecoration(
          gradient: gradient, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 8)],
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ]),
        ),
      ),
    );
  }
}

// ── App Card ─────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final double radius;

  const AppCard({super.key, required this.child, this.padding, this.onTap, this.color, this.gradient, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? AppColors.card) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: child,
      ),
    );
  }
}

// ── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        if (action != null)
          GestureDetector(onTap: onAction, child: Text(action!, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500))),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const AppEmptyState({super.key, required this.icon, required this.title, this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle), child: Icon(icon, size: 48, color: AppColors.primary)),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center),
          if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center)],
          if (actionLabel != null && onAction != null) ...[const SizedBox(height: 24), ElevatedButton(onPressed: onAction, child: Text(actionLabel!))],
        ]),
      ),
    );
  }
}

// ── Shimmer Card ──────────────────────────────────────────────────────────────
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool verified;
  const InfoRow({super.key, required this.icon, required this.label, required this.value, this.verified = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ])),
        if (verified) const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
      ]),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.iconColor, required this.iconBg});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}

// ── Gradient Header ───────────────────────────────────────────────────────────
class GradientHeader extends StatelessWidget {
  final Widget child;
  final double height;
  const GradientHeader({super.key, required this.child, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: height,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(child: child),
    );
  }
}

// ── Snackbar helper ───────────────────────────────────────────────────────────
void showSnack(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      Icon(isError ? Icons.error_rounded : Icons.check_circle_rounded, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(msg)),
    ]),
    backgroundColor: isError ? AppColors.error : AppColors.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    duration: const Duration(seconds: 2),
  ));
}
