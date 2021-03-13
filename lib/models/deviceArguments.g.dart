// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deviceArguments.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceArgumentsAdapter extends TypeAdapter<DeviceArguments> {
  @override
  final int typeId = 1;

  @override
  DeviceArguments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceArguments(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceArguments obj) {
    writer
      ..writeByte(3)..writeByte(0)
      ..write(obj.deviceName)
      ..writeByte(1)
      ..write(obj.ip)
      ..writeByte(2)
      ..write(obj.apiKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DeviceArgumentsAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
