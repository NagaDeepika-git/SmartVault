import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/vault_card.dart';
import '../products/product_provider.dart';
import 'service_provider.dart';

/// Chronological timeline screen of all service, maintenance, and repair records.
class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadAllRecords();
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final serviceProvider = context.watch<ServiceProvider>();
    final productProvider = context.watch<ProductProvider>();
    final records = serviceProvider.records;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service & Repairs'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(RouteNames.serviceForm),
        backgroundColor: AppColors.champagne,
        foregroundColor: const Color(0xFF1A1300),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Service', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ResponsiveContentContainer(
        child: Column(
          children: [
            // Cost Summary Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: VaultCard(
                padding: const EdgeInsets.all(18.0),
                backgroundColor: AppColors.champagne.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.champagne.withValues(alpha: 0.3)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Maintenance Expenditure',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(serviceProvider.totalOverallServiceCost),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.champagne,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.champagne.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_rounded, color: AppColors.champagne, size: 24),
                    ),
                  ],
                ),
              ),
            ),

            // Records Timeline List
            Expanded(
              child: serviceProvider.isLoading
                  ? const LoadingStateView(message: 'Loading maintenance history...')
                  : records.isEmpty
                      ? EmptyStateView.noServices(
                          onAdd: () => Navigator.of(context).pushNamed(RouteNames.serviceForm),
                        )
                      : RefreshIndicator(
                          onRefresh: () => serviceProvider.loadAllRecords(),
                          color: AppColors.champagne,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              final product = productProvider.products
                                  .where((p) => p.id == record.productId)
                                  .firstOrNull;

                              return VaultCard(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product?.name ?? 'Tracked Asset',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(record.cost, symbol: product?.currency ?? '\$'),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.champagne,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${record.serviceProvider} • ${DateFormatter.formatDate(record.serviceDate)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                    const Divider(height: 16),
                                    Text(
                                      record.issueDescription,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    if (record.resolution != null && record.resolution!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Resolution: ${record.resolution!}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                    if (record.nextMaintenanceDate != null) ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.event_repeat_rounded, size: 14, color: AppColors.info),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Next Maintenance: ${DateFormatter.formatDate(record.nextMaintenanceDate)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.info,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
