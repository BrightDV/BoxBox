// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_tracker.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 1;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as DateTime,
      fields[5] as DateTime,
      fields[6] as bool,
      fields[7] as Session,
      fields[8] as Session,
      fields[9] as Session,
      fields[10] as Session,
      fields[11] as Session,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.raceId)
      ..writeByte(1)
      ..write(obj.meetingName)
      ..writeByte(2)
      ..write(obj.meetingOfficialName)
      ..writeByte(3)
      ..write(obj.meetingCountryName)
      ..writeByte(4)
      ..write(obj.meetingStartDate)
      ..writeByte(5)
      ..write(obj.meetingEndDate)
      ..writeByte(6)
      ..write(obj.isRunning)
      ..writeByte(7)
      ..write(obj.session5)
      ..writeByte(8)
      ..write(obj.session4)
      ..writeByte(9)
      ..write(obj.session3)
      ..writeByte(10)
      ..write(obj.session2)
      ..writeByte(11)
      ..write(obj.session1);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
