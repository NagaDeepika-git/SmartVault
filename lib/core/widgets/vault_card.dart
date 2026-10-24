import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Premium dimensional card component embodying the SmartVault aesthetic.
/// Features subtle gradient depth, delicate metallic border highlights, and tactile feedback.
class VaultCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Border? border;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final bool hasGlow;

  const VaultCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = AppSpacing.cardPadding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.borderRadius = AppRadius.lg,
    this.shadows,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final defaultBorderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final defaultShadows = shadows ?? (isDark ? AppShadows.subtleDark : AppShadows.cardElevation);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? defaultBg) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: defaultBorderColor, width: 1.0),
        boxShadow: hasGlow ? AppShadows.vaultGlow : defaultShadows,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.champagne.withValues(alpha: 0.12),
          highlightColor: AppColors.champagne.withValues(alpha: 0.05),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
