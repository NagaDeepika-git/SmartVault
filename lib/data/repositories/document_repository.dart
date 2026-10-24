import '../datasources/local_database_service.dart';
import '../models/document_model.dart';

/// Repository interface and local database implementation for Document management.
abstract class DocumentRepository {
  Future<List<DocumentModel>> getAllDocuments();
  Future<DocumentModel?> getDocumentById(String id);
  Future<List<DocumentModel>> getDocumentsByCategory(DocumentCategory category);
  Future<List<DocumentModel>> getDocumentsByProductId(String productId);
  Future<List<DocumentModel>> getFavoriteDocuments();
  Future<void> createDocument(DocumentModel document);
  Future<void> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String id);
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<List<DocumentModel>> searchDocuments(String query, {DocumentCategory? category, bool? onlyFavorites});
}

class LocalDocumentRepository implements DocumentRepository {
  final LocalDatabaseService _dbService;

  LocalDocumentRepository({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService.instance;

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    final maps = await _dbService.query(
      LocalDatabaseService.tableDocuments,
      orderBy: 'created_at',
      descending: true,
    );
    return maps.map((map) => DocumentModel.fromMap(map)).toList();
  }

  @override
  Future<DocumentModel?> getDocumentById(String id) async {
    final all = await getAllDocuments();
    try {
      return all.firstWhere((doc) => doc.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DocumentModel>> getDocumentsByCategory(DocumentCategory category) async {
    final all = await getAllDocuments();
    return all.where((doc) => doc.category == category).toList();
  }

  @override
  Future<List<DocumentModel>> getDocumentsByProductId(String productId) async {
    final all = await getAllDocuments();
    return all.where((doc) => doc.productId == productId).toList();
  }

  @override
  Future<List<DocumentModel>> getFavoriteDocuments() async {
    final all = await getAllDocuments();
    return all.where((doc) => doc.isFavorite).toList();
  }

  @override
  Future<void> createDocument(DocumentModel document) async {
    await _dbService.insert(
      LocalDatabaseService.tableDocuments,
      document.toMap(),
    );
  }

  @override
  Future<void> updateDocument(DocumentModel document) async {
    await _dbService.update(
      LocalDatabaseService.tableDocuments,
      document.toMap(),
      id: document.id,
    );
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _dbService.delete(
      LocalDatabaseService.tableDocuments,
      id: id,
    );
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final doc = await getDocumentById(id);
    if (doc != null) {
      final updated = doc.copyWith(isFavorite: isFavorite);
      await updateDocument(updated);
    }
  }

  @override
  Future<List<DocumentModel>> searchDocuments(
    String query, {
    DocumentCategory? category,
    bool? onlyFavorites,
  }) async {
    final all = await getAllDocuments();
    final cleanQuery = query.trim().toLowerCase();

    return all.where((doc) {
      if (category != null && doc.category != category) return false;
      if (onlyFavorites == true && !doc.isFavorite) return false;
      if (cleanQuery.isEmpty) return true;

      final titleMatch = doc.title.toLowerCase().contains(cleanQuery);
      final descMatch = doc.description?.toLowerCase().contains(cleanQuery) ?? false;
      final issuerMatch = doc.issuer?.toLowerCase().contains(cleanQuery) ?? false;
      final notesMatch = doc.notes?.toLowerCase().contains(cleanQuery) ?? false;
      final tagMatch = doc.tags.any((t) => t.toLowerCase().contains(cleanQuery));

      return titleMatch || descMatch || issuerMatch || notesMatch || tagMatch;
    }).toList();
  }
}
