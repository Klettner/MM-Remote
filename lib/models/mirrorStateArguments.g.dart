// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mirrorStateArguments.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MirrorStateArgumentsAdapter extends TypeAdapter<MirrorStateArguments> {
  @override
  final int typeId = 2;

  @override
  MirrorStateArguments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MirrorStateArguments(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MirrorStateArguments obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.deviceName)
      ..writeByte(1)
      ..write(obj.brightness)
      ..writeByte(2)
      ..write(obj.alertDuration)
      ..writeByte(3)
      ..write(obj.monitorStatus)
      ..writeByte(4)
      ..write(obj.volume)
      ..writeByte(5)
      ..write(obj.previousVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MirrorStateArgumentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
