import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'client.g.dart';

@HiveType(typeId: 0)
class Client extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  late String email;

  @HiveField(4)
  late String address;

  Client({
    String? id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  }) : id = id ?? const Uuid().v4();
}
