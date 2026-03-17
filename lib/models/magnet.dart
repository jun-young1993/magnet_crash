import 'magnet_type.dart';

class Magnet {
  final String id;
  final double x;
  final double y;
  final MagnetType type;
  final int groupId;
  final int ownerId;

  const Magnet({
    required this.id,
    required this.x,
    required this.y,
    required this.type,
    required this.groupId,
    required this.ownerId,
  });

  Magnet copyWith({
    String? id,
    double? x,
    double? y,
    MagnetType? type,
    int? groupId,
    int? ownerId,
  }) {
    return Magnet(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
      groupId: groupId ?? this.groupId,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Magnet && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
