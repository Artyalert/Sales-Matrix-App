import 'package:flutter_bloc/flutter_bloc.dart';
import 'sales_event.dart';
import 'sales_state.dart';
import '../../data/models/sale_model.dart';
import '../../data/datasources/sales_local_datasource.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesLocalDataSource dataSource;

  // Holds complete unfiltered dataset
  List<SaleModel> _allSales = [];

  SalesBloc(this.dataSource) : super(SalesInitial()) {
    on<LoadSalesData>(_onLoadSales);
    on<ApplySalesFilter>(_onApplyFilter);
  }

  // ================= LOAD SALES DATA =================
  Future<void> _onLoadSales(
    LoadSalesData event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoading());

    try {
      final sales = await dataSource.loadSales();

      if (sales.isEmpty) {
        emit(SalesError('No sales data found'));
        return;
      }

      _allSales = List.from(sales);

      emit(_buildState(
        all: _allSales,
        filtered: _allSales,
      ));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  // ================= APPLY BRAND FILTER =================
  void _onApplyFilter(
    ApplySalesFilter event,
    Emitter<SalesState> emit,
  ) {
    final filtered = event.brand == null || event.brand!.isEmpty
        ? _allSales
        : _allSales.where((e) => e.brand == event.brand).toList();

    emit(_buildState(
      all: _allSales,
      filtered: filtered,
    ));
  }

  // ================= BUILD STATE =================
  SalesLoaded _buildState({
    required List<SaleModel> all,
    required List<SaleModel> filtered,
  }) {
    final totalSales = all.fold<double>(0, (sum, e) => sum + e.salesAmount);

    final activeStores = all.where((e) => e.isActiveStore).length;

    final topBrand = _getTopBrand(all);

    return SalesLoaded(
      allSales: all,
      filteredSales: filtered,
      totalSales: totalSales,
      activeStores: activeStores,
      topBrand: topBrand,
    );
  }

  // ================= TOP BRAND =================
  String _getTopBrand(List<SaleModel> data) {
    if (data.isEmpty) return 'N/A';

    final Map<String, double> brandTotals = {};

    for (final s in data) {
      brandTotals[s.brand] = (brandTotals[s.brand] ?? 0) + s.salesAmount;
    }

    return brandTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
