import 'package:flutter/foundation.dart';
import '../../core/errors/error_handler.dart';
import '../../data/models/document_model.dart';
import '../../data/repositories/document_repository.dart';

enum DocumentSortOption {
  dateCreated('Recently Added'),
  title('Title (A-Z)'),
  expiryDate('Expiration Date');

  final String label;
  const DocumentSortOption(this.label);
}

/// Central state manager for the Document & Certificate Vault module.
/// Implements ChangeNotifier with notifyListeners for responsive UI updates.
class DocumentProvider extends ChangeNotifier {
  final DocumentRepository _repository;

  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  String? _errorMessage;

  DocumentCategory? _selectedCategory;
  String _searchQuery = '';
  bool _onlyFavorites = false;
  DocumentSortOption _sortOption = DocumentSortOption.dateCreated;

  DocumentProvider({DocumentRepository? repository})
      : _repository = repository ?? LocalDocumentRepository();

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DocumentCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get onlyFavorites => _onlyFavorites;
  DocumentSortOption get sortOption => _sortOption;

  /// Returns dynamically filtered and sorted documents based on active user filters.
  List<DocumentModel> get filteredDocuments {
    var result = List<DocumentModel>.from(_documents);

    // Filter by Category
    if (_selectedCategory != null) {
      result = result.where((doc) => doc.category == _selectedCategory).toList();
    }

    // Filter by Favorites
    if (_onlyFavorites) {
      result = result.where((doc) => doc.isFavorite).toList();
    }

    // Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((doc) {
        final matchesTitle = doc.title.toLowerCase().contains(q);
        final matchesIssuer = doc.issuer?.toLowerCase().contains(q) ?? false;
        final matchesNotes = doc.notes?.toLowerCase().contains(q) ?? false;
        final matchesTags = doc.tags.any((t) => t.toLowerCase().contains(q));
        return matchesTitle || matchesIssuer || matchesNotes || matchesTags;
      }).toList();
    }

    // Sort Records
    switch (_sortOption) {
      case DocumentSortOption.dateCreated:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DocumentSortOption.title:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case DocumentSortOption.expiryDate:
        result.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
    }

    return result;
  }

  int get totalCount => _documents.length;
  int get favoritesCount => _documents.where((d) => d.isFavorite).length;

  int countForCategory(DocumentCategory category) {
    return _documents.where((d) => d.category == category).length;
  }

  Future<void> loadDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _documents = await _repository.getAllDocuments();
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('loadDocuments', error: e, stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(DocumentCategory? category) {
    _selectedCategory = category;
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

  void setSortOption(DocumentSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _onlyFavorites = false;
    _sortOption = DocumentSortOption.dateCreated;
    notifyListeners();
  }

  Future<bool> createDocument(DocumentModel document) async {
    try {
      await _repository.createDocument(document);
      _documents.insert(0, document);
      notifyListeners();
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('createDocument', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDocument(DocumentModel document) async {
    try {
      await _repository.updateDocument(document);
      final index = _documents.indexWhere((d) => d.id == document.id);
      if (index != -1) {
        _documents[index] = document;
        notifyListeners();
      }
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('updateDocument', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      await _repository.deleteDocument(id);
      _documents.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('deleteDocument', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index != -1) {
      final newFavState = !_documents[index].isFavorite;
      final updated = _documents[index].copyWith(isFavorite: newFavState);
      _documents[index] = updated;
      notifyListeners();

      try {
        await _repository.toggleFavorite(id, newFavState);
      } catch (e, stack) {
        // Revert on failure
        _documents[index] = _documents[index].copyWith(isFavorite: !newFavState);
        _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
        ErrorHandler.logSafe('toggleFavorite', error: e, stackTrace: stack);
        notifyListeners();
      }
    }
  }

  DocumentModel? getDocumentById(String id) {
    try {
      return _documents.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
