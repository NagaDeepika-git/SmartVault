import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../data/models/document_model.dart';
import 'document_provider.dart';
import 'widgets/document_card.dart';

/// Complete Document Vault view with instant search, category chips, sorting, and favorites filter.
class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().loadDocuments();
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
    final provider = context.watch<DocumentProvider>();
    final docs = provider.filteredDocuments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Vault'),
        actions: [
          IconButton(
            icon: Icon(
              provider.onlyFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: provider.onlyFavorites ? AppColors.error : null,
            ),
            tooltip: 'Filter Favorites',
            onPressed: () => provider.toggleOnlyFavorites(),
          ),
          PopupMenuButton<DocumentSortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Documents',
            onSelected: (option) => provider.setSortOption(option),
            itemBuilder: (context) => DocumentSortOption.values.map((opt) {
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
        heroTag: 'fab_documents',
        onPressed: () => Navigator.of(context).pushNamed(RouteNames.documentForm),
        backgroundColor: AppColors.champagne,
        foregroundColor: const Color(0xFF1A1300),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Document', style: TextStyle(fontWeight: FontWeight.w700)),
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
                  hintText: 'Search title, issuer, tags, or notes...',
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

            // Horizontal Category Filter Tabs
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // 'All' Chip
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('All (${provider.totalCount})'),
                      selected: provider.selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) provider.setCategory(null);
                      },
                      selectedColor: AppColors.champagne,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: provider.selectedCategory == null
                            ? const Color(0xFF1A1300)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),

                  // Category Chips
                  ...DocumentCategory.values.map((cat) {
                    final count = provider.categoryCounts[cat] ?? 0;
                    final isSelected = provider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text('${cat.label} ($count)'),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.setCategory(selected ? cat : null);
                        },
                        selectedColor: AppColors.champagne,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF1A1300)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Document List
            Expanded(
              child: provider.isLoading
                  ? const LoadingStateView(message: 'Loading secure documents...')
                  : docs.isEmpty
                      ? provider.searchQuery.isNotEmpty || provider.selectedCategory != null || provider.onlyFavorites
                          ? EmptyStateView.noSearchResults(
                              query: provider.searchQuery.isNotEmpty ? provider.searchQuery : 'selected filters',
                              onReset: () {
                                _searchController.clear();
                                provider.resetFilters();
                              },
                            )
                          : EmptyStateView.noDocuments(
                              onAdd: () => Navigator.of(context).pushNamed(RouteNames.documentForm),
                            )
                      : RefreshIndicator(
                          onRefresh: () => provider.loadDocuments(),
                          color: AppColors.champagne,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              return DocumentCard(
                                document: doc,
                                onTap: () => Navigator.of(context).pushNamed(
                                  RouteNames.documentDetail,
                                  arguments: doc.id,
                                ),
                                onToggleFavorite: () => provider.toggleFavorite(doc.id),
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
