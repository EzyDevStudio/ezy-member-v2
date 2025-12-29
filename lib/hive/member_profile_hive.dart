import 'package:hive/hive.dart';

part 'member_profile_hive.g.dart';

@HiveType(typeId: 0)
class MemberProfileHive extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String memberCode;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String token;

  @HiveField(4)
  final String image;

  @HiveField(5)
  final String backgroundImage;

  MemberProfileHive({
    required this.id,
    required this.memberCode,
    required this.name,
    required this.token,
    required this.image,
    required this.backgroundImage,
  });

  MemberProfileHive copyWith({int? id, String? memberCode, String? name, String? token, String? image, String? backgroundImage}) => MemberProfileHive(
    id: id ?? this.id,
    memberCode: memberCode ?? this.memberCode,
    name: name ?? this.name,
    token: token ?? this.token,
    image: image ?? this.image,
    backgroundImage: backgroundImage ?? this.backgroundImage,
  );
}
