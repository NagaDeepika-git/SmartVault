import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/warranty_calculator.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../data/models/product_model.dart';
import 'product_provider.dart';
import 'widgets/product_card.dart';

/// Product & Asset Inventory list view with warranty filter chips, search, and portfolio summary.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();
    final products = provider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets & Inventory'),
        actions: [
          IconButton(
            icon: Icon(
              provider.onlyFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: provider.onlyFavorites ? AppColors.error : null,
            ),
            tooltip: 'Filter Favorites',
            onPressed: () => provider.toggleOnlyFavorites(),
          ),
          PopupMenuButton<ProductSortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Products',
            onSelected: (option) => provider.setSortOption(option),
            itemBuilder: (context) => ProductSortOption.values.map((opt) {
              return PopupMenuItem(
                value: opt,
                child: Row(
                  children: [
                    if (provider.sortOption == opt)
                      const Icon(Icons.check_rounded, size: 16, color: AppColors.champagne)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(opt.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(RouteNames.productForm),
        backgroundColor: AppColors.champagne,
        foregroundColor: const Color(0xFF1A1300),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Register Asset', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ResponsiveContentContainer(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => provider.setSearchQuery(val),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products by name, brand, model...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.champagne),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Summary Metric Pill Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Value',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatCompact(provider.totalPortfolioValue),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.champagne),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Warranties',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                          Text(
                            '${provider.activeWarrantyCount} Active',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expiring Soon',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                          Text(
                            '${provider.expiringSoonCount} Assets',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.warning),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Horizontal Warranty Status Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text('All (${provider.totalCount})'),
                      selected: provider.selectedWarrantyStatus == null && provider.selectedCategory == null,
                      onSelected: (_) => provider.resetFilters(),
                      selectedColor: AppColors.champagne,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text('Active (${provider.activeWarrantyCount})'),
                      selected: provider.selectedWarrantyStatus == WarrantyStatus.active,
                      onSelected: (selected) {
                        provider.setWarrantyStatus(selected ? WarrantyStatus.active : null);
                      },
                      selectedColor: AppColors.champagne,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text('Expiring Soon (${provider.expiringSoonCount})'),
                      selected: provider.selectedWarrantyStatus == WarrantyStatus.expiringSoon,
                      onSelected: (selected) {
                        provider.setWarrantyStatus(selected ? WarrantyStatus.expiringSoon : null);
                      },
                      selectedColor: AppColors.champagne,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text('Expired (${provider.expiredCount})'),
                      selected: provider.selectedWarrantyStatus == WarrantyStatus.expired,
                      onSelected: (selected) {
                        provider.setWarrantyStatus(selected ? WarrantyStatus.expired : null);
                      },
                      selectedColor: AppColors.champagne,
                    ),
                  ),
                  ...ProductCategory.values.map((cat) {
                    final isSelected = provider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(cat.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.setCategory(selected ? cat : null);
                        },
                        selectedColor: AppColors.champagne,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Product List
            Expanded(
              child: provider.isLoading
                  ? const LoadingStateView(message: 'Loading assets and products...')
                  : products.isEmpty
                      ? provider.searchQuery.isNotEmpty || provider.selectedWarrantyStatus != null || provider.selectedCategory != null
                          ? EmptyStateView.noSearchResults(
                              query: provider.searchQuery.isNotEmpty ? provider.searchQuery : 'selected filters',
                              onReset: () {
                                _searchController.clear();
                                provider.resetFilters();
                              },
                            )
                          : EmptyStateView.noProducts(
                              onAdd: () => Navigator.of(context).pushNamed(RouteNames.productForm),
                            )
                      : RefreshIndicator(
                          onRefresh: () => provider.loadProducts(),
                          color: AppColors.champagne,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                product: product,
                                onTap: () => Navigator.of(context).pushNamed(
                                  RouteNames.productDetail,
                                  arguments: product.id,
                                ),
                                onToggleFavorite: () => provider.toggleFavorite(product.id),
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
