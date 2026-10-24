import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../utils/warranty_calculator.dart';

/// Refined status badge and indicator pill for warranty states, categories, and tags.
class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color? backgroundColor;
  final bool isFilled;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    this.backgroundColor,
    this.isFilled = false,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  });

  /// Factory constructor configured for WarrantyStatus values.
  factory StatusBadge.fromWarrantyStatus(WarrantyStatus status, {String? customLabel}) {
    switch (status) {
      case WarrantyStatus.active:
        return StatusBadge(
          label: customLabel ?? 'Active',
          icon: Icons.verified_user_rounded,
          color: AppColors.success,
          backgroundColor: AppColors.successBackground,
        );
      case WarrantyStatus.expiringSoon:
        return StatusBadge(
          label: customLabel ?? 'Expiring Soon',
          icon: Icons.hourglass_top_rounded,
          color: AppColors.warning,
          backgroundColor: AppColors.warningBackground,
        );
      case WarrantyStatus.expired:
        return StatusBadge(
          label: customLabel ?? 'Expired',
          icon: Icons.history_rounded,
          color: AppColors.error,
          backgroundColor: AppColors.errorBackground,
        );
      case WarrantyStatus.unknown:
        return const StatusBadge(
          label: 'No Warranty',
          icon: Icons.help_outline_rounded,
          color: AppColors.textSecondaryDark,
          backgroundColor: Color(0x1F94A3B8),
        );
    }
  }

  /// Factory constructor for Demo/Sample data badge.
  factory StatusBadge.sample() {
    return const StatusBadge(
      label: 'Demo',
      icon: Icons.science_outlined,
      color: Color(0xFF94A3B8),
      fontSize: 10.0,
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? color.withValues(alpha: 0.15);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isFilled ? color : effectiveBg,
        borderRadius: AppRadius.radiusFull,
        border: Border.all(
          color: isFilled ? Colors.transparent : color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: isFilled ? Colors.white : color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: isFilled ? Colors.white : color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
