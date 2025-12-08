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

  MemberProfileHive({required this.id, required this.memberCode, required this.name});
}
