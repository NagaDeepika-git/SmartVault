import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/services/currency_api_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/vault_card.dart';
import '../../data/models/document_model.dart';
import '../../data/models/product_model.dart';
import '../documents/document_provider.dart';
import '../products/product_provider.dart';
import '../service_history/service_provider.dart';

/// Analytics & Insights Screen.
/// Computes and presents portfolio distribution, category breakdowns, warranty health,
/// and live FX currency valuation.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final CurrencyApiService _currencyService = CurrencyApiService();
  String _selectedTargetCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    await _currencyService.fetchRates();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _currencyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final docProvider = context.watch<DocumentProvider>();
    final prodProvider = context.watch<ProductProvider>();
    final servProvider = context.watch<ServiceProvider>();

    final totalPortfolioUsd = prodProvider.totalInventoryValue;
    final convertedPortfolioValue = _currencyService.convert(
      totalPortfolioUsd,
      'USD',
      _selectedTargetCurrency,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
      ),
      body: ResponsiveContentContainer(
        maxWidth: 1000,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              docProvider.loadDocuments(),
              prodProvider.loadProducts(),
              servProvider.loadAllRecords(),
              _currencyService.fetchRates(forceRefresh: true),
            ]);
          },
          color: AppColors.champagne,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            children: [
              // Portfolio Valuation & Live FX Conversion Card
              _buildPortfolioCard(
                totalPortfolioUsd,
                convertedPortfolioValue,
                isDark,
              ),
              const SizedBox(height: 18),

              // KPI Row
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Maintenance Spend',
                      value: servProvider.totalOverallServiceCost,
                      prefix: '\$',
                      icon: Icons.receipt_long_rounded,
                      accentColor: AppColors.champagne,
                      decimalPlaces: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Active Warranties',
                      value: prodProvider.activeWarrantyCount,
                      icon: Icons.verified_user_rounded,
                      accentColor: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Warranty Breakdown Section
              _buildWarrantyHealthSection(prodProvider, isDark),
              const SizedBox(height: 20),

              // Document Category Distribution
              _buildDocumentCategoriesSection(docProvider, isDark),
              const SizedBox(height: 20),

              // Asset Category Distribution
              _buildAssetCategoriesSection(prodProvider, isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioCard(
    double totalUsd,
    double convertedValue,
    bool isDark,
  ) {
    return VaultCard(
      padding: const EdgeInsets.all(20.0),
      backgroundColor: isDark ? const Color(0xFF162544) : const Color(0xFF1E293B),
      border: Border.all(color: AppColors.champagne.withValues(alpha: 0.4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Asset Valuation',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              DropdownButton<String>(
                value: _selectedTargetCurrency,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: AppColors.champagne, fontWeight: FontWeight.w700),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                  DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
                  DropdownMenuItem(value: 'CAD', child: Text('CAD (\$)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTargetCurrency = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(
              convertedValue,
              symbol: _getCurrencySymbol(_selectedTargetCurrency),
            ),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                _currencyService.error != null
                    ? Icons.cloud_off_rounded
                    : Icons.check_circle_outline_rounded,
                size: 14,
                color: _currencyService.error != null ? AppColors.warning : AppColors.success,
              ),
              const SizedBox(width: 6),
              Text(
                _currencyService.error != null
                    ? 'Using cached FX exchange rates'
                    : 'Live exchange rates via open.er-api.com',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantyHealthSection(ProductProvider prodProvider, bool isDark) {
    final active = prodProvider.activeWarrantyCount;
    final expiring = prodProvider.expiringSoonWarrantyCount;
    final expired = prodProvider.expiredWarrantyCount;
    final total = active + expiring + expired;

    return VaultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Warranty Health Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (total == 0)
            const Text('No warranty information recorded for tracked assets.')
          else ...[
            ClipRRect(
              borderRadius: AppRadius.radiusFull,
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    if (active > 0)
                      Expanded(
                        flex: active,
                        child: Container(color: AppColors.success),
                      ),
                    if (expiring > 0)
                      Expanded(
                        flex: expiring,
                        child: Container(color: AppColors.warning),
                      ),
                    if (expired > 0)
                      Expanded(
                        flex: expired,
                        child: Container(color: AppColors.error),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Active', active, AppColors.success),
                _buildLegendItem('Expiring Soon', expiring, AppColors.warning),
                _buildLegendItem('Expired', expired, AppColors.error),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label ($count)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDocumentCategoriesSection(DocumentProvider docProvider, bool isDark) {
    final docs = docProvider.documents;
    final total = docs.length;

    return VaultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Documents by Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                '$total Total',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (total == 0)
            const Text('No documents uploaded.')
          else
            ...DocumentCategory.values.map((cat) {
              final count = docs.where((d) => d.category == cat).length;
              if (count == 0) return const SizedBox.shrink();
              final percent = (count / total);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        Text('$count (${(percent * 100).toInt()}%)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.champagne),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAssetCategoriesSection(ProductProvider prodProvider, bool isDark) {
    final products = prodProvider.products;
    final total = products.length;

    return VaultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assets by Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                '$total Total',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (total == 0)
            const Text('No assets registered.')
          else
            ...ProductCategory.values.map((cat) {
              final count = products.where((p) => p.category == cat).length;
              if (count == 0) return const SizedBox.shrink();
              final percent = (count / total);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        Text('$count (${(percent * 100).toInt()}%)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'CAD':
        return 'CA\$';
      default:
        return '\$';
    }
  }
}
