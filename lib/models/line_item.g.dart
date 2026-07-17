// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LineItemAdapter extends TypeAdapter<LineItem> {
  @override
  final int typeId = 2;

  @override
  LineItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LineItem(
      productName: fields[0] as String,
      quantity: fields[1] as int,
      unitPrice: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LineItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.productName)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unitPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
