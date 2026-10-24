import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/app_exceptions.dart';

/// Robust local persistence service storing structured JSON entity collections.
/// Guarantees data persistence across restarts on Web, Android, iOS, Windows, macOS, and Linux.
class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  LocalDatabaseService._init();

  static const String tableDocuments = 'smartvault_table_documents';
  static const String tableProducts = 'smartvault_table_products';
  static const String tableServiceRecords = 'smartvault_table_service_records';
  static const String tableReminders = 'smartvault_table_reminders';
  static const String keyIsSeeded = 'smartvault_data_is_seeded';

  SharedPreferences? _prefs;
  final Map<String, List<Map<String, dynamic>>> _memoryCache = {};

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Initializes the storage service and loads cached records into memory.
  Future<void> init() async {
    try {
      final prefs = await _preferences;
      for (final table in [
        tableDocuments,
        tableProducts,
        tableServiceRecords,
        tableReminders,
      ]) {
        final rawJson = prefs.getString(table);
        if (rawJson != null && rawJson.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
          _memoryCache[table] = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } else {
          _memoryCache[table] = [];
        }
      }
    } catch (e, stack) {
      throw DatabaseException('Failed to initialize local persistence service: $e', details: stack);
    }
  }

  Future<void> _persistTable(String table) async {
    final prefs = await _preferences;
    final list = _memoryCache[table] ?? [];
    final jsonString = jsonEncode(list);
    await prefs.setString(table, jsonString);
  }

  /// Queries all records from a given table with optional filtering and sorting.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? orderBy,
    bool descending = true,
  }) async {
    if (!_memoryCache.containsKey(table)) {
      await init();
    }

    var results = List<Map<String, dynamic>>.from(_memoryCache[table] ?? []);

    if (orderBy != null && results.isNotEmpty) {
      results.sort((a, b) {
        final valA = a[orderBy];
        final valB = b[orderBy];
        if (valA == null && valB == null) return 0;
        if (valA == null) return descending ? 1 : -1;
        if (valB == null) return descending ? -1 : 1;

        final comp = Comparable.compare(
          valA is Comparable ? valA : valA.toString(),
          valB is Comparable ? valB : valB.toString(),
        );
        return descending ? -comp : comp;
      });
    }

    return results;
  }

  /// Inserts a new record into the specified table.
  Future<void> insert(String table, Map<String, dynamic> data) async {
    if (!_memoryCache.containsKey(table)) {
      await init();
    }

    final list = _memoryCache[table] ?? [];
    // Remove if existing id to prevent duplicates
    final id = data['id'];
    list.removeWhere((item) => item['id'] == id);
    list.add(Map<String, dynamic>.from(data));
    _memoryCache[table] = list;

    await _persistTable(table);
  }

  /// Updates an existing record by id.
  Future<void> update(String table, Map<String, dynamic> data, {required String id}) async {
    if (!_memoryCache.containsKey(table)) {
      await init();
    }

    final list = _memoryCache[table] ?? [];
    final index = list.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      list[index] = Map<String, dynamic>.from(data);
      _memoryCache[table] = list;
      await _persistTable(table);
    } else {
      // If not present, insert
      await insert(table, data);
    }
  }

  /// Deletes a record by id.
  Future<void> delete(String table, {required String id}) async {
    if (!_memoryCache.containsKey(table)) {
      await init();
    }

    final list = _memoryCache[table] ?? [];
    list.removeWhere((item) => item['id'] == id);
    _memoryCache[table] = list;

    await _persistTable(table);
  }

  /// Checks if a table has any records.
  Future<bool> hasData(String table) async {
    if (!_memoryCache.containsKey(table)) {
      await init();
    }
    return (_memoryCache[table] ?? []).isNotEmpty;
  }

  /// Clears an entire table.
  Future<void> clearTable(String table) async {
    final prefs = await _preferences;
    _memoryCache[table] = [];
    await prefs.remove(table);
  }

  /// Clears all tables and resets seed flag.
  Future<void> clearAll() async {
    final prefs = await _preferences;
    for (final table in [
      tableDocuments,
      tableProducts,
      tableServiceRecords,
      tableReminders,
    ]) {
      _memoryCache[table] = [];
      await prefs.remove(table);
    }
    await prefs.remove(keyIsSeeded);
  }

  /// Checks whether sample data has been seeded.
  Future<bool> isSeeded() async {
    final prefs = await _preferences;
    return prefs.getBool(keyIsSeeded) ?? false;
  }

  /// Sets the seeded flag.
  Future<void> setSeeded(bool seeded) async {
    final prefs = await _preferences;
    await prefs.setBool(keyIsSeeded, seeded);
  }
}
