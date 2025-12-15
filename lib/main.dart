

import 'package:sales_matrix_app/utils/exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('sales_cache');

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // Add New Application

  @override
  Widget build(BuildContext context) {
    return appBlocProviders(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (_) =>  SalesDashboardScreen(),
          '/invoice': (_) =>  InvoiceCompareScreen(),
        },
      ),
    );
  }
}
