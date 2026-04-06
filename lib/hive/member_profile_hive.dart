import 'dart:typed_data';

import 'package:ezymember/constants/enum.dart';
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
  final Uint8List? image;

  @HiveField(5)
  final Uint8List? backgroundImage;

  @HiveField(6)
  final Uint8List? personalInvoice;

  @HiveField(7)
  final Uint8List? workingInvoice;

  MemberProfileHive({
    required this.id,
    required this.memberCode,
    required this.name,
    required this.token,
    this.image,
    this.backgroundImage,
    this.personalInvoice,
    this.workingInvoice,
  });

  MemberProfileHive copyWith({
    int? id,
    String? memberCode,
    String? name,
    String? token,
    Uint8List? image,
    Uint8List? backgroundImage,
    Uint8List? personalInvoice,
    Uint8List? workingInvoice,
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

  MemberProfileHive clearMedia(MediaType type) {
    switch (type) {
      case MediaType.image:
        return MemberProfileHive(
          id: id,
          memberCode: memberCode,
          name: name,
          token: token,
          image: null,
          backgroundImage: backgroundImage,
          personalInvoice: personalInvoice,
          workingInvoice: workingInvoice,
        );
      case MediaType.background:
        return MemberProfileHive(
          id: id,
          memberCode: memberCode,
          name: name,
          token: token,
          image: image,
          backgroundImage: null,
          personalInvoice: personalInvoice,
          workingInvoice: workingInvoice,
        );
      case MediaType.personalInvoice:
        return MemberProfileHive(
          id: id,
          memberCode: memberCode,
          name: name,
          token: token,
          image: image,
          backgroundImage: backgroundImage,
          personalInvoice: null,
          workingInvoice: workingInvoice,
        );
      case MediaType.workingInvoice:
        return MemberProfileHive(
          id: id,
          memberCode: memberCode,
          name: name,
          token: token,
          image: image,
          backgroundImage: backgroundImage,
          personalInvoice: personalInvoice,
          workingInvoice: null,
        );
    }
  }
}
