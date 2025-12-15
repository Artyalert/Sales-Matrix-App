import 'package:sales_matrix_app/utils/exports.dart';

class SalesLocalDataSource {
  static const _boxName = 'sales_cache';
  static const _cacheKey = 'sales';

  Box get _box => Hive.box(_boxName);

  Future<List<SaleModel>> loadSales() async {
    final cached = _box.get(_cacheKey);

    // ================= SAFE CACHE READ =================
    if (cached != null && cached is List) {
      try {
        final list = cached
            .where((e) => e != null && e is Map)
            .map((e) => SaleModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList();

        if (list.isNotEmpty) {
          print('HIVE CACHE HIT: ${list.length}');
          return list;
        }
      } catch (e) {
        print('HIVE CACHE CORRUPT → FALLBACK TO JSON');
      }
    }

    // ================= JSON FALLBACK =================
    print('LOADING SALES FROM JSON');

    final jsonString = await rootBundle.loadString('assets/data/sales.json');

    final decoded = json.decode(jsonString);

    if (decoded is! List) {
      throw Exception('Invalid JSON structure');
    }

    final sales = decoded
        .where((e) => e != null && e is Map)
        .map((e) => SaleModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();

    // ================= CACHE WRITE =================
    await _box.put(
      _cacheKey,
      sales.map((e) => e.toJson()).toList(),
    );

    return sales;
  }
}
