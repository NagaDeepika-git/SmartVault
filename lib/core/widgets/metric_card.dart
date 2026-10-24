import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'vault_card.dart';

/// Smooth animated number counter widget for dashboard and analytics metrics.
/// Addresses syllabus animation requirement using TweenAnimationBuilder.
class AnimatedCounter extends StatelessWidget {
  final num value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final int decimalPlaces;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.decimalPlaces = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        final formattedNumber = decimalPlaces > 0
            ? animatedValue.toStringAsFixed(decimalPlaces)
            : animatedValue.toInt().toString();

        return Text(
          '${prefix ?? ''}$formattedNumber${suffix ?? ''}',
          style: style ?? AppTypography.metricValue,
        );
      },
    );
  }
}

/// Interactive Metric card component for Vault analytics and dashboard statistics.
class MetricCard extends StatelessWidget {
  final String title;
  final num value;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;
  final String? prefix;
  final String? suffix;
  final int decimalPlaces;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor = AppColors.champagne,
    this.onTap,
    this.prefix,
    this.suffix,
    this.decimalPlaces = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return VaultCard(
      onTap: onTap,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: secondaryTextColor.withValues(alpha: 0.6),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCounter(
            value: value,
            prefix: prefix,
            suffix: suffix,
            decimalPlaces: decimalPlaces,
            style: AppTypography.metricValue.copyWith(
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: secondaryTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
