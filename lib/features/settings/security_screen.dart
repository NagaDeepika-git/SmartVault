import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/vault_card.dart';

/// Security & Privacy Preferences screen.
/// Implements PIN lock configuration, serial number masking, and privacy documentation.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isPinLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSecurityPreferences();
  }

  Future<void> _loadSecurityPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPinLockEnabled = prefs.getBool('security_pin_enabled') ?? false;
    });
  }

  Future<void> _togglePinLock(bool value) async {
    if (value) {
      _showSetPinDialog();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('security_pin_enabled', false);
      setState(() => _isPinLockEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vault PIN Lock disabled')),
        );
      }
    }
  }

  void _showSetPinDialog() {
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set 4-Digit Vault PIN'),
          content: Form(
            key: formKey,
            child: CustomTextField(
              controller: pinController,
              label: 'PIN Code',
              hint: '4-digit PIN',
              prefixIcon: Icons.lock_outline_rounded,
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (val) => Validators.pin(val),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('security_pin_enabled', true);
                await prefs.setString('security_pin_hash', pinController.text.trim());
                if (ctx.mounted) Navigator.of(ctx).pop();
                setState(() {
                  _isPinLockEnabled = true;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vault PIN Lock activated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.champagne,
                foregroundColor: const Color(0xFF1A1300),
              ),
              child: const Text('Activate PIN'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Privacy'),
      ),
      body: ResponsiveContentContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            // PIN Lock Protection Card
            VaultCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                title: const Text('Vault Access PIN', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  _isPinLockEnabled
                      ? 'Protected: Requires 4-digit PIN on application launch'
                      : 'Disabled: Anyone with device access can view records',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                secondary: const Icon(Icons.pin_rounded, color: AppColors.champagne),
                value: _isPinLockEnabled,
                activeThumbColor: AppColors.champagne,
                onChanged: _togglePinLock,
              ),
            ),
            const SizedBox(height: 20),

            // Sensitive Identifier Protection
            VaultCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.visibility_off_outlined, color: AppColors.amber, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Serial Number & IMEI Masking',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'SmartVault automatically masks all hardware serial numbers and device IMEI identifiers in standard list views and cards (e.g. ••••••••MD6R). Sensitive values are only revealed when you explicitly tap the reveal icon on the asset detail view.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Privacy Architecture Explanation
            VaultCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.success, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Offline-First Local Privacy',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '1. Zero Cloud Sync: Your certificates, identification numbers, and asset purchase values reside strictly in your device\'s local storage.\n\n'
                    '2. App Locking vs. Database Encryption: A PIN lock restricts UI access. True hardware file-level encryption is managed by the underlying operating system sandbox.\n\n'
                    '3. Zero Telemetry of Personal Records: Error and diagnostic handlers explicitly strip all personal fields, document paths, and serial identifiers from logs.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
