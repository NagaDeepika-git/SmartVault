import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/warranty_calculator.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/vault_card.dart';
import '../../data/models/product_model.dart';
import '../products/product_provider.dart';

/// Dedicated Warranty Management and Countdown view.
/// Shows active, expiring soon, and expired product warranties with progress timelines.
class WarrantyOverviewScreen extends StatefulWidget {
  const WarrantyOverviewScreen({super.key});

  @override
  State<WarrantyOverviewScreen> createState() => _WarrantyOverviewScreenState();
}

class _WarrantyOverviewScreenState extends State<WarrantyOverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterByTab(List<ProductModel> products, int tabIndex) {
    final withWarranty = products.where((p) => p.hasWarranty).toList();

    switch (tabIndex) {
      case 1: // Expiring Soon
        return withWarranty.where((p) => p.warrantyResult.status == WarrantyStatus.expiringSoon).toList();
      case 2: // Active
        return withWarranty.where((p) => p.warrantyResult.status == WarrantyStatus.active).toList();
      case 3: // Expired
        return withWarranty.where((p) => p.warrantyResult.status == WarrantyStatus.expired).toList();
      default: // All
        return withWarranty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();
    final allProducts = provider.products;

    final expiringSoon = allProducts.where((p) => p.warrantyResult.status == WarrantyStatus.expiringSoon).toList();
    final active = allProducts.where((p) => p.warrantyResult.status == WarrantyStatus.active).toList();
    final expired = allProducts.where((p) => p.warrantyResult.status == WarrantyStatus.expired).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warranty Center'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.champagne,
          labelColor: AppColors.champagne,
          unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          tabs: [
            Tab(text: 'All (${allProducts.where((p) => p.hasWarranty).length})'),
            Tab(text: 'Expiring (${expiringSoon.length})'),
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Expired (${expired.length})'),
          ],
        ),
      ),
      body: ResponsiveContentContainer(
        child: TabBarView(
          controller: _tabController,
          children: List.generate(4, (tabIndex) {
            final items = _filterByTab(allProducts, tabIndex);

            if (items.isEmpty) {
              return EmptyStateView(
                icon: Icons.hourglass_empty_rounded,
                title: 'No Warranties in this Category',
                message: tabIndex == 1
                    ? 'No products are currently expiring soon. All warranties are healthy!'
                    : 'No warrantied assets found in this category.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                final warranty = product.warrantyResult;

                return VaultCard(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      RouteNames.productDetail,
                      arguments: product.id,
                    );
                  },
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  '${product.brand ?? ''} • ${product.category.label}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge.fromWarrantyStatus(warranty.status),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Countdown & Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            warranty.statusLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: warranty.isExpired
                                  ? AppColors.error
                                  : warranty.isExpiringSoon
                                      ? AppColors.warning
                                      : AppColors.success,
                            ),
                          ),
                          Text(
                            'Expires ${DateFormatter.formatDate(product.warrantyEndDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: AppRadius.radiusFull,
                        child: LinearProgressIndicator(
                          value: warranty.progress,
                          minHeight: 6,
                          backgroundColor: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            warranty.isExpired
                                ? AppColors.error
                                : warranty.isExpiringSoon
                                    ? AppColors.warning
                                    : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
