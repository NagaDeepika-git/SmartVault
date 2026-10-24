import 'package:flutter/foundation.dart';
import '../../core/errors/error_handler.dart';
import '../../core/utils/warranty_calculator.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

enum ProductSortOption {
  purchaseDate('Purchase Date'),
  name('Name (A-Z)'),
  price('Purchase Price'),
  warrantyEnd('Warranty Expiry');

  final String label;
  const ProductSortOption(this.label);
}

/// Central state manager for the Product & Asset Inventory module.
class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProductCategory? _selectedCategory;
  WarrantyStatus? _selectedWarrantyStatus;
  String _searchQuery = '';
  bool _onlyFavorites = false;
  ProductSortOption _sortOption = ProductSortOption.purchaseDate;

  ProductProvider({ProductRepository? repository})
      : _repository = repository ?? LocalProductRepository();

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProductCategory? get selectedCategory => _selectedCategory;
  WarrantyStatus? get selectedWarrantyStatus => _selectedWarrantyStatus;
  String get searchQuery => _searchQuery;
  bool get onlyFavorites => _onlyFavorites;
  ProductSortOption get sortOption => _sortOption;

  List<ProductModel> get filteredProducts {
    var result = List<ProductModel>.from(_products);

    if (_selectedCategory != null) {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    if (_selectedWarrantyStatus != null) {
      result = result.where((p) => p.warrantyResult.status == _selectedWarrantyStatus).toList();
    }

    if (_onlyFavorites) {
      result = result.where((p) => p.isFavorite).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((p) {
        final matchesName = p.name.toLowerCase().contains(q);
        final matchesBrand = p.brand?.toLowerCase().contains(q) ?? false;
        final matchesModel = p.model?.toLowerCase().contains(q) ?? false;
        final matchesSeller = p.seller?.toLowerCase().contains(q) ?? false;
        return matchesName || matchesBrand || matchesModel || matchesSeller;
      }).toList();
    }

    switch (_sortOption) {
      case ProductSortOption.purchaseDate:
        result.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
      case ProductSortOption.name:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case ProductSortOption.price:
        result.sort((a, b) => (b.purchasePrice ?? 0).compareTo(a.purchasePrice ?? 0));
        break;
      case ProductSortOption.warrantyEnd:
        result.sort((a, b) {
          if (a.warrantyEndDate == null && b.warrantyEndDate == null) return 0;
          if (a.warrantyEndDate == null) return 1;
          if (b.warrantyEndDate == null) return -1;
          return a.warrantyEndDate!.compareTo(b.warrantyEndDate!);
        });
        break;
    }

    return result;
  }

  int get totalCount => _products.length;
  int get activeWarrantyCount => _products.where((p) => p.warrantyResult.status == WarrantyStatus.active).length;
  int get expiringSoonWarrantyCount => _products.where((p) => p.warrantyResult.status == WarrantyStatus.expiringSoon).length;
  int get expiredWarrantyCount => _products.where((p) => p.warrantyResult.status == WarrantyStatus.expired).length;

  double get totalInventoryValue {
    return _products.fold<double>(0.0, (sum, p) => sum + (p.purchasePrice ?? 0.0));
  }

  int countForCategory(ProductCategory category) {
    return _products.where((p) => p.category == category).length;
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('loadProducts', error: e, stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(ProductCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setWarrantyStatus(WarrantyStatus? status) {
    _selectedWarrantyStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _onlyFavorites = !_onlyFavorites;
    notifyListeners();
  }

  void setSortOption(ProductSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = null;
    _selectedWarrantyStatus = null;
    _searchQuery = '';
    _onlyFavorites = false;
    _sortOption = ProductSortOption.purchaseDate;
    notifyListeners();
  }

  Future<bool> createProduct(ProductModel product) async {
    try {
      await _repository.createProduct(product);
      _products.insert(0, product);
      notifyListeners();
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('createProduct', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _repository.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('updateProduct', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('deleteProduct', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final newFavState = !_products[index].isFavorite;
      final updated = _products[index].copyWith(isFavorite: newFavState);
      _products[index] = updated;
      notifyListeners();

      try {
        await _repository.toggleFavorite(id, newFavState);
      } catch (e, stack) {
        _products[index] = _products[index].copyWith(isFavorite: !newFavState);
        _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
        ErrorHandler.logSafe('toggleFavoriteProduct', error: e, stackTrace: stack);
        notifyListeners();
      }
    }
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
