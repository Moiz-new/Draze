import 'package:draze/landlord/models/room_model.dart';

class RoomService {
  final List<Room> _rooms = [];

  Future<List<Room>> getRoomsByProperty(String propertyId) async {
    await Future.delayed(Duration(seconds: 1));
    return _rooms.where((room) => room.propertyId == propertyId).toList();
  }

  Future<void> addRoom(Room room) async {
    await Future.delayed(Duration(seconds: 1));
    _rooms.add(room);
  }

  Future<void> updateRoom(Room room) async {
    await Future.delayed(Duration(seconds: 1));
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      _rooms[index] = room;
    }
  }

  Future<void> deleteRoom(String roomId) async {
    await Future.delayed(Duration(seconds: 1));
    _rooms.removeWhere((r) => r.id == roomId);
  }

  Future<Room?> getRoom(String roomId) async {
    await Future.delayed(Duration(seconds: 1));
    try {
      return _rooms.firstWhere((r) => r.id == roomId);
    } catch (e) {
      return null;
    }
  }
}
