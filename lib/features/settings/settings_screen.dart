import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/theme_provider.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/vault_card.dart';
import '../../data/datasources/local_database_service.dart';
import '../../data/datasources/sample_data_loader.dart';
import '../documents/document_provider.dart';
import '../products/product_provider.dart';
import '../reminders/reminder_provider.dart';
import '../service_history/service_provider.dart';

/// Settings & Preferences Screen.
/// Configures app theme, security settings, sample data reload, and platform metadata.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _resetSampleData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reset Sample Data?'),
          content: const Text(
            'This will clear current demo records and reload the curated initial sample dataset. Any user custom records will be preserved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.champagne,
                foregroundColor: const Color(0xFF1A1300),
              ),
              child: const Text('Reload Sample Data'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await SampleDataLoader.seedSampleData(LocalDatabaseService.instance);
      if (!context.mounted) return;
      await Future.wait([
        context.read<DocumentProvider>().loadDocuments(),
        context.read<ProductProvider>().loadProducts(),
        context.read<ServiceProvider>().loadAllRecords(),
        context.read<ReminderProvider>().loadReminders(),
      ]);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample data reloaded successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ResponsiveContentContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            // Appearance Section
            _buildSectionHeader('APPEARANCE & THEME'),
            VaultCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      isDark ? 'Midnight Navy Dark Theme active' : 'Clean Light Surface active',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    secondary: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.champagne,
                    ),
                    value: isDark,
                    activeThumbColor: AppColors.champagne,
                    onChanged: (val) => themeProvider.toggleTheme(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security & Privacy
            _buildSectionHeader('SECURITY & PRIVACY'),
            VaultCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security_rounded, color: AppColors.champagne),
                    title: const Text('Security & Access Protection', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('PIN lock, local storage encryption, and privacy rules', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pushNamed(RouteNames.security),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data Management
            _buildSectionHeader('DATA MANAGEMENT'),
            VaultCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.refresh_rounded, color: AppColors.amber),
                    title: const Text('Reload Sample Dataset', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Restore initial portfolio of demo products and certificates', style: TextStyle(fontSize: 12)),
                    onTap: () => _resetSampleData(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.folder_shared_outlined, color: AppColors.info),
                    title: const Text('Local Storage Engine', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('JSON Collections via SharedPreferences Engine (100% Offline)', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About SmartVault
            _buildSectionHeader('ABOUT SMARTVAULT'),
            VaultCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.champagne.withValues(alpha: 0.15),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: const Icon(Icons.shield_rounded, color: AppColors.champagne, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SmartVault', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          Text('Version 1.0.0 (Production Release)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '"Your records. Your assets. One intelligent vault."',
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Built with Flutter & Dart. Combines personal document management with intelligent real-time warranty tracking and service history.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.champagne,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
