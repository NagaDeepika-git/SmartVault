import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/vault_card.dart';
import '../documents/document_provider.dart';
import '../products/product_provider.dart';
import '../reminders/reminder_provider.dart';
import '../service_history/service_provider.dart';

/// Premium Dashboard for SmartVault.
/// Displays unified health metrics, vault hero overview, expiring warranties, and quick actions.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().loadDocuments();
      context.read<ProductProvider>().loadProducts();
      context.read<ServiceProvider>().loadAllRecords();
      context.read<ReminderProvider>().loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final docProvider = context.watch<DocumentProvider>();
    final prodProvider = context.watch<ProductProvider>();
    final servProvider = context.watch<ServiceProvider>();
    final remProvider = context.watch<ReminderProvider>();

    final expiringProducts = prodProvider.products
        .where((p) => p.warrantyResult.isExpiringSoon)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.champagne.withValues(alpha: 0.15),
                borderRadius: AppRadius.radiusSm,
              ),
              child: const Icon(Icons.shield_rounded, color: AppColors.champagne, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('SmartVault', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_rounded),
                if (remProvider.pendingCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                    ),
                  ),
              ],
            ),
            tooltip: 'Reminders & Alerts',
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.reminders),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Universal Search',
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.search),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContentContainer(
        maxWidth: 1100,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              docProvider.loadDocuments(),
              prodProvider.loadProducts(),
              servProvider.loadAllRecords(),
              remProvider.loadReminders(),
            ]);
          },
          color: AppColors.champagne,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            children: [
              // Vault Hero Banner
              _buildVaultHero(context, isDark),
              const SizedBox(height: 20),

              // KPI Metric Cards Grid
              _buildMetricsGrid(context, docProvider, prodProvider),
              const SizedBox(height: 20),

              // Quick Actions Bar
              _buildQuickActions(context, isDark),
              const SizedBox(height: 24),

              // Expiring Warranties Alert Banner
              if (expiringProducts.isNotEmpty) ...[
                _buildExpiringAlert(context, expiringProducts),
                const SizedBox(height: 24),
              ],

              // Recent Documents Section
              _buildRecentDocuments(context, docProvider, isDark),
              const SizedBox(height: 24),

              // Tracked Assets Overview
              _buildTrackedAssets(context, prodProvider, isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultHero(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusLg,
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF162544), const Color(0xFF0F172A)]
              : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.champagne.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.champagne.withValues(alpha: 0.18),
                  borderRadius: AppRadius.radiusSm,
                  border: Border.all(color: AppColors.champagne.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.champagne),
                    SizedBox(width: 6),
                    Text(
                      'SECURE LOCAL VAULT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.champagne,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.shield_outlined, color: AppColors.champagne, size: 28),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Your records. Your assets.\nOne intelligent vault.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unified offline-first certificate management and warranty tracking.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    DocumentProvider docProvider,
    ProductProvider prodProvider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth > 700 ? 1.4 : 1.3,
          children: [
            MetricCard(
              title: 'Total Documents',
              value: docProvider.totalCount,
              icon: Icons.folder_copy_rounded,
              accentColor: AppColors.champagne,
              onTap: () => Navigator.of(context).pushNamed(RouteNames.documents),
            ),
            MetricCard(
              title: 'Tracked Assets',
              value: prodProvider.totalCount,
              icon: Icons.devices_other_rounded,
              accentColor: AppColors.amber,
              onTap: () => Navigator.of(context).pushNamed(RouteNames.products),
            ),
            MetricCard(
              title: 'Active Warranties',
              value: prodProvider.activeWarrantiesCount,
              icon: Icons.verified_user_rounded,
              accentColor: AppColors.success,
              onTap: () => Navigator.of(context).pushNamed(RouteNames.warrantyOverview),
            ),
            MetricCard(
              title: 'Expiring Soon',
              value: prodProvider.expiringSoonWarrantiesCount,
              icon: Icons.hourglass_top_rounded,
              accentColor: AppColors.warning,
              onTap: () => Navigator.of(context).pushNamed(RouteNames.warrantyOverview),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      {
        'label': 'Add Document',
        'icon': Icons.note_add_rounded,
        'route': RouteNames.documentForm,
      },
      {
        'label': 'Register Asset',
        'icon': Icons.add_circle_outline_rounded,
        'route': RouteNames.productForm,
      },
      {
        'label': 'Log Service',
        'icon': Icons.build_circle_outlined,
        'route': RouteNames.serviceForm,
      },
      {
        'label': 'Warranties',
        'icon': Icons.verified_outlined,
        'route': RouteNames.warrantyOverview,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed(item['route'] as String),
                  borderRadius: AppRadius.radiusMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item['icon'] as IconData, color: AppColors.champagne, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          item['label'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpiringAlert(BuildContext context, List expiringProducts) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${expiringProducts.length} Product Warranties Expiring Soon!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(RouteNames.warrantyOverview),
                child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...expiringProducts.take(2).map((p) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('• ${p.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    p.warrantyResult.statusLabel,
                    style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentDocuments(BuildContext context, DocumentProvider docProvider, bool isDark) {
    final recentDocs = docProvider.documents.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Documents',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.documents),
              child: const Text('View Vault', style: TextStyle(color: AppColors.champagne)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentDocs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text('No documents added yet.'),
          )
        else
          ...recentDocs.map((doc) {
            return VaultCard(
              margin: const EdgeInsets.only(bottom: 8.0),
              onTap: () {
                Navigator.of(context).pushNamed(
                  RouteNames.documentDetail,
                  arguments: doc.id,
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.champagne.withValues(alpha: 0.12),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: const Icon(Icons.description_rounded, color: AppColors.champagne, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${doc.category.label} • ${DateFormatter.formatDate(doc.createdAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTrackedAssets(BuildContext context, ProductProvider prodProvider, bool isDark) {
    final recentProducts = prodProvider.products.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tracked Assets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.products),
              child: const Text('View All Assets', style: TextStyle(color: AppColors.champagne)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text('No products tracked yet.'),
          )
        else
          ...recentProducts.map((prod) {
            return VaultCard(
              margin: const EdgeInsets.only(bottom: 8.0),
              onTap: () {
                Navigator.of(context).pushNamed(
                  RouteNames.productDetail,
                  arguments: prod.id,
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.12),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: const Icon(Icons.devices_rounded, color: AppColors.amber, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${prod.brand ?? ''} • ${prod.category.label}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.fromWarrantyStatus(prod.warrantyResult.status),
                ],
              ),
            );
          }),
      ],
    );
  }
}
