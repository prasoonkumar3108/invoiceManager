import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double unitPrice;

  Product({
    String? id,
    required this.name,
    required this.unitPrice,
  }) : id = id ?? const Uuid().v4();
}
