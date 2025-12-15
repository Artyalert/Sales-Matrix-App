import 'package:sales_matrix_app/utils/exports.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();

    /// Auto load data from Hive / JSON
    context.read<SalesBloc>().add(LoadSalesData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          // ================= LOADING =================
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ================= LOADED =================
          if (state is SalesLoaded) {
            // ---------- FILTERED DATA (Charts) ----------
            final monthlySales = getMonthlySales(state.filteredSales);

            final regionStores = getActiveStoresByRegion(state.filteredSales);

            // ---------- GLOBAL DATA (KPIs) ----------
            final currentYear = DateTime.now().year;
            final lastYear = currentYear - 1;

            final currentYearSales =
                getYearlySales(state.allSales, currentYear);
            final lastYearSales = getYearlySales(state.allSales, lastYear);

            final yoyGrowth = lastYearSales == 0
                ? 0
                : ((currentYearSales - lastYearSales) / lastYearSales) * 100;

            final brands = state.allSales.map((e) => e.brand).toSet().toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ================= KPI ROW =================
                  Row(
                    children: [
                      _kpiCard(
                        title: 'Total Sales',
                        value: '₹${state.totalSales.toStringAsFixed(0)}',
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _kpiCard(
                        title: 'Active Stores',
                        value: '${state.activeStores}',
                        icon: Icons.store,
                        color: AppColors.skyBlue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _kpiCard(
                        title: 'Top Brand',
                        value: state.topBrand,
                        icon: Icons.star,
                        color: AppColors.orange,
                      ),
                      const SizedBox(width: 12),
                      _kpiCard(
                        title: 'YoY Growth',
                        value: '${yoyGrowth.toStringAsFixed(1)}%',
                        icon: Icons.show_chart,
                        color: yoyGrowth >= 0
                            ? AppColors.green
                            : AppColors.redColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= BRAND FILTER =================
                  DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Brand',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Brands'),
                      ),
                      ...brands.map(
                        (b) => DropdownMenuItem(
                          value: b,
                          child: Text(b),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand = value;
                      });
                      context.read<SalesBloc>().add(
                            ApplySalesFilter(brand: value),
                          );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ================= CHARTS =================
                  _sectionCard(
                    title: 'Monthly Sales Trend',
                    child: monthlySales.isEmpty
                        ? const Center(
                            child: Text('No data available'),
                          )
                        : MonthlySalesChart(data: monthlySales),
                  ),

                  const SizedBox(height: 20),

                  _sectionCard(
                    title: 'Active Stores by Region',
                    child: regionStores.isEmpty
                        ? const Center(child: Text('No data available'))
                        : RegionStoreChart(data: regionStores),
                  ),

                  const SizedBox(height: 30),

                  // ================= NAVIGATION =================
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/invoice');
                    },
                    icon: const Icon(Icons.compare),
                    label: const Text('Open Invoice Comparison'),
                  ),
                ],
              ),
            );
          }

          // ================= ERROR =================
          if (state is SalesError) {
            return Center(child: Text(state.message));
          }

          // ================= INITIAL =================
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<SalesBloc>().add(LoadSalesData());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load Sales Data'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/invoice');
                  },
                  icon: const Icon(Icons.compare),
                  label: const Text('Open Invoice Comparison'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
