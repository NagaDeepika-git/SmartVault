import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// High quality empty state component for lists, search results, and category filters.
/// Avoids blank empty screens by presenting contextual advice and direct primary action buttons.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  factory EmptyStateView.noDocuments({VoidCallback? onAdd}) {
    return EmptyStateView(
      icon: Icons.folder_open_rounded,
      title: 'No Documents in Vault',
      message: 'Store your degree certificates, invoices, passport, and records securely in one place.',
      actionLabel: onAdd != null ? 'Add First Document' : null,
      onAction: onAdd,
      iconColor: AppColors.champagne,
    );
  }

  factory EmptyStateView.noProducts({VoidCallback? onAdd}) {
    return EmptyStateView(
      icon: Icons.inventory_2_outlined,
      title: 'No Products Tracked',
      message: 'Track your laptops, smartphones, and household appliances with real-time warranty countdowns.',
      actionLabel: onAdd != null ? 'Register Asset' : null,
      onAction: onAdd,
      iconColor: AppColors.amber,
    );
  }

  factory EmptyStateView.noServices({VoidCallback? onAdd}) {
    return EmptyStateView(
      icon: Icons.build_circle_outlined,
      title: 'No Service History',
      message: 'Log maintenance, repairs, battery replacements, and calculate total lifetime costs.',
      actionLabel: onAdd != null ? 'Add Service Entry' : null,
      onAction: onAdd,
      iconColor: AppColors.info,
    );
  }

  factory EmptyStateView.noReminders() {
    return const EmptyStateView(
      icon: Icons.notifications_none_rounded,
      title: 'All Caught Up!',
      message: 'You have no pending reminders or upcoming expirations at this time.',
      iconColor: AppColors.success,
    );
  }

  factory EmptyStateView.noSearchResults({required String query, VoidCallback? onReset}) {
    return EmptyStateView(
      icon: Icons.search_off_rounded,
      title: 'No Matching Records',
      message: 'We could not find any records matching "$query". Try checking spelling or relaxing filters.',
      actionLabel: onReset != null ? 'Reset All Filters' : null,
      onAction: onReset,
      iconColor: AppColors.textMutedDark,
    );
  }

  factory EmptyStateView.error({required String message, VoidCallback? onRetry}) {
    return EmptyStateView(
      icon: Icons.error_outline_rounded,
      title: 'Unable to Load Records',
      message: message,
      actionLabel: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
      iconColor: AppColors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ?? AppColors.champagne;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.champagne,
                  foregroundColor: const Color(0xFF1A1300),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Polished loading state with animated pulse indicator.
class LoadingStateView extends StatelessWidget {
  final String message;

  const LoadingStateView({
    super.key,
    this.message = 'Loading vault records...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.champagne),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
