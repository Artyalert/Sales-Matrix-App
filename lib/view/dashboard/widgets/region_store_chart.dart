import 'package:sales_matrix_app/utils/exports.dart';


/// A bar chart widget that displays the number of stores in different regions.
class RegionStoreChart extends StatelessWidget {
  final Map<String, int> data;

  const RegionStoreChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final regions = data.keys.toList();

    final barGroups = data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.value.toDouble(),
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(6),
            width: 18,
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),

          // ================= TITLES =================
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            // Y AXIS (Store Count)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),

            // X AXIS (Region Names)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= regions.length) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      regions[index],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
