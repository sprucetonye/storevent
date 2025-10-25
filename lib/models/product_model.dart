import 'package:hive/hive.dart';




@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String name;
  //
  @HiveField(1)
  final String quantity;
  //
  @HiveField(2)
  final String price;
  //
  
  @HiveField(3)
  final String imagePath;
  //
  Product( {
    required this.name,
    required this.quantity,
    required this.price,
    required this.imagePath,
  });
}