import '../datasources/local_database_service.dart';
import '../models/product_model.dart';
import '../../core/utils/warranty_calculator.dart';

/// Repository interface and local database implementation for Product and Warranty management.
abstract class ProductRepository {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel?> getProductById(String id);
  Future<List<ProductModel>> getProductsByCategory(ProductCategory category);
  Future<List<ProductModel>> getProductsByWarrantyStatus(WarrantyStatus status);
  Future<List<ProductModel>> getFavoriteProducts();
  Future<void> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<List<ProductModel>> searchProducts(String query, {ProductCategory? category, WarrantyStatus? status});
  Future<List<ProductModel>> getExpiringWarranties({int daysThreshold = 30});
}

class LocalProductRepository implements ProductRepository {
  final LocalDatabaseService _dbService;

  LocalProductRepository({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService.instance;

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final maps = await _dbService.query(
      LocalDatabaseService.tableProducts,
      orderBy: 'purchase_date',
      descending: true,
    );
    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final all = await getAllProducts();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(ProductCategory category) async {
    final all = await getAllProducts();
    return all.where((p) => p.category == category).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByWarrantyStatus(WarrantyStatus status) async {
    final all = await getAllProducts();
    return all.where((p) => p.warrantyResult.status == status).toList();
  }

  @override
  Future<List<ProductModel>> getFavoriteProducts() async {
    final all = await getAllProducts();
    return all.where((p) => p.isFavorite).toList();
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    await _dbService.insert(
      LocalDatabaseService.tableProducts,
      product.toMap(),
    );
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _dbService.update(
      LocalDatabaseService.tableProducts,
      product.toMap(),
      id: product.id,
    );
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _dbService.delete(
      LocalDatabaseService.tableProducts,
      id: id,
    );
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final product = await getProductById(id);
    if (product != null) {
      final updated = product.copyWith(isFavorite: isFavorite);
      await updateProduct(updated);
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(
    String query, {
    ProductCategory? category,
    WarrantyStatus? status,
  }) async {
    final all = await getAllProducts();
    final cleanQuery = query.trim().toLowerCase();

    return all.where((p) {
      if (category != null && p.category != category) return false;
      if (status != null && p.warrantyResult.status != status) return false;
      if (cleanQuery.isEmpty) return true;

      final nameMatch = p.name.toLowerCase().contains(cleanQuery);
      final brandMatch = p.brand?.toLowerCase().contains(cleanQuery) ?? false;
      final modelMatch = p.model?.toLowerCase().contains(cleanQuery) ?? false;
      final serialMatch = p.serialNumber?.toLowerCase().contains(cleanQuery) ?? false;
      final sellerMatch = p.seller?.toLowerCase().contains(cleanQuery) ?? false;

      return nameMatch || brandMatch || modelMatch || serialMatch || sellerMatch;
    }).toList();
  }

  @override
  Future<List<ProductModel>> getExpiringWarranties({int daysThreshold = 30}) async {
    final all = await getAllProducts();
    return all.where((p) {
      final res = p.warrantyResult;
      return res.status == WarrantyStatus.expiringSoon;
    }).toList();
  }
}
