import 'package:hive/hive.dart';

part 'member_profile_hive.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

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

  @HiveField(6)
  final String personalInvoice;

  @HiveField(7)
  final String workingInvoice;

  MemberProfileHive({
    required this.id,
    required this.memberCode,
    required this.name,
    required this.token,
    required this.image,
    required this.backgroundImage,
    required this.personalInvoice,
    required this.workingInvoice,
  });

  MemberProfileHive copyWith({
    int? id,
    String? memberCode,
    String? name,
    String? token,
    String? image,
    String? backgroundImage,
    String? personalInvoice,
    String? workingInvoice,
  }) => MemberProfileHive(
    id: id ?? this.id,
    memberCode: memberCode ?? this.memberCode,
    name: name ?? this.name,
    token: token ?? this.token,
    image: image ?? this.image,
    backgroundImage: backgroundImage ?? this.backgroundImage,
    personalInvoice: personalInvoice ?? this.personalInvoice,
    workingInvoice: workingInvoice ?? this.workingInvoice,
  );
}
