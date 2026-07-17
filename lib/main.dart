import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'package:invoicemanager/models/client.dart';
import 'package:invoicemanager/models/product.dart';
import 'package:invoicemanager/models/line_item.dart';
import 'package:invoicemanager/models/invoice.dart';
import 'package:invoicemanager/providers/invoice_provider.dart';
import 'package:invoicemanager/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);

  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(LineItemAdapter());
  Hive.registerAdapter(InvoiceAdapter());

  await Hive.openBox<Client>('clients');
  await Hive.openBox<Product>('products');
  await Hive.openBox<Invoice>('invoices');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
      ],
      child: MaterialApp(
        title: 'Offline Invoice & Billing Generator',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(
            secondary: Colors.amber,
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
