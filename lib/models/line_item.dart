import 'package:hive/hive.dart';

part 'line_item.g.dart';

@HiveType(typeId: 2)
class LineItem extends HiveObject {
  @HiveField(0)
  late String productName;

  @HiveField(1)
  late int quantity;

  @HiveField(2)
  late double unitPrice;

  LineItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}
