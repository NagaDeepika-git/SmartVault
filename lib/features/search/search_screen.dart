import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/vault_card.dart';
import '../../data/models/document_model.dart';
import '../../data/models/product_model.dart';
import '../documents/document_provider.dart';
import '../products/product_provider.dart';

enum SearchFilterType { all, documents, assets }

/// Universal Search Screen across all Documents and Products.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchFilterType _filterType = SearchFilterType.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allDocs = context.watch<DocumentProvider>().documents;
    final allProducts = context.watch<ProductProvider>().products;

    final q = _query.trim().toLowerCase();

    List<DocumentModel> matchedDocs = [];
    List<ProductModel> matchedProducts = [];

    if (q.isNotEmpty) {
      if (_filterType == SearchFilterType.all || _filterType == SearchFilterType.documents) {
        matchedDocs = allDocs.where((d) {
          return d.title.toLowerCase().contains(q) ||
              (d.description?.toLowerCase().contains(q) ?? false) ||
              d.category.label.toLowerCase().contains(q) ||
              d.tags.any((t) => t.toLowerCase().contains(q));
        }).toList();
      }

      if (_filterType == SearchFilterType.all || _filterType == SearchFilterType.assets) {
        matchedProducts = allProducts.where((p) {
          return p.name.toLowerCase().contains(q) ||
              (p.brand?.toLowerCase().contains(q) ?? false) ||
              (p.model?.toLowerCase().contains(q) ?? false) ||
              (p.serialNumber?.toLowerCase().contains(q) ?? false) ||
              p.category.label.toLowerCase().contains(q);
        }).toList();
      }
    }

    final totalResults = matchedDocs.length + matchedProducts.length;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search documents, serials, warranties...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (val) => setState(() => _query = val),
        ),
      ),
      body: ResponsiveContentContainer(
        child: Column(
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildFilterChip('All', SearchFilterType.all),
                  const SizedBox(width: 8),
                  _buildFilterChip('Documents', SearchFilterType.documents),
                  const SizedBox(width: 8),
                  _buildFilterChip('Assets & Products', SearchFilterType.assets),
                ],
              ),
            ),
            const Divider(height: 1),

            // Results List
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 64,
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search across your Vault',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Find passports, degree certificates, devices by serial or brand.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : totalResults == 0
                      ? EmptyStateView.noSearchResults(
                          query: _query,
                          onReset: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          children: [
                            Text(
                              '$totalResults Result(s) Found',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Document Results
                            if (matchedDocs.isNotEmpty) ...[
                              Text(
                                'DOCUMENTS (${matchedDocs.length})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.champagne,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...matchedDocs.map((doc) => _buildDocResult(context, doc, isDark)),
                              const SizedBox(height: 16),
                            ],

                            // Product Results
                            if (matchedProducts.isNotEmpty) ...[
                              Text(
                                'ASSETS & PRODUCTS (${matchedProducts.length})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.amber,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...matchedProducts.map((prod) => _buildProductResult(context, prod, isDark)),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, SearchFilterType type) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.champagne.withValues(alpha: 0.2),
      checkmarkColor: AppColors.champagne,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.champagne : null,
      ),
      onSelected: (_) => setState(() => _filterType = type),
    );
  }

  Widget _buildDocResult(BuildContext context, DocumentModel doc, bool isDark) {
    return VaultCard(
      margin: const EdgeInsets.only(bottom: 8.0),
      onTap: () {
        Navigator.of(context).pushNamed(RouteNames.documentDetail, arguments: doc.id);
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
  }

  Widget _buildProductResult(BuildContext context, ProductModel prod, bool isDark) {
    return VaultCard(
      margin: const EdgeInsets.only(bottom: 8.0),
      onTap: () {
        Navigator.of(context).pushNamed(RouteNames.productDetail, arguments: prod.id);
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
  }
}
