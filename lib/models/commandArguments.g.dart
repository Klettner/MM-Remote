// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commandArguments.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommandArgumentsAdapter extends TypeAdapter<CommandArguments> {
  @override
  final int typeId = 3;

  @override
  CommandArguments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommandArguments(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CommandArguments obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.deviceName)
      ..writeByte(1)
      ..write(obj.commandName)
      ..writeByte(2)
      ..write(obj.notification)
      ..writeByte(3)
      ..write(obj.payload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandArgumentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
