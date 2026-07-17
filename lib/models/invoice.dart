import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:invoicemanager/models/client.dart';
import 'package:invoicemanager/models/line_item.dart';

part 'invoice.g.dart';

@HiveType(typeId: 3)
class Invoice extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late Client client;

  @HiveField(2)
  late List<LineItem> lineItems;

  @HiveField(3)
  late DateTime issueDate;

  @HiveField(4)
  late DateTime dueDate;

  @HiveField(5)
  late double? tax;

  @HiveField(6)
  late double? discount;

  Invoice({
    String? id,
    required this.client,
    required this.lineItems,
    required this.issueDate,
    required this.dueDate,
    this.tax,
    this.discount,
  }) : id = id ?? const Uuid().v4();

  double get subtotal => lineItems.fold(0.0, (sum, item) => sum + item.total);

  double get total {
    double totalAmount = subtotal;
    if (tax != null) {
      totalAmount += totalAmount * (tax! / 100);
    }
    if (discount != null) {
      totalAmount -= totalAmount * (discount! / 100);
    }
    return totalAmount;
  }
}
