import 'package:flutter/material.dart';
import 'package:onielsstore/utils/notifications_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onielsstore/models/product_model.dart';
import 'package:onielsstore/screens/product_list_screen.dart';
import 'package:onielsstore/screens/dashboard_screen.dart';
//import 'package:onielsstore/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Product>('products');
  NotificationsManager.initialize();
  Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  DashboardScreen(),
    );



  }
}
