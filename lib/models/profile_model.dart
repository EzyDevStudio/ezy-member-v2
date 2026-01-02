import 'package:ezy_member_v2/helpers/formatter_helper.dart';

// Common fields
const String fieldID = "id";
const String fieldMemberCode = "member_code";
const String fieldCountryCode = "country_code";
const String fieldContactNumber = "contact_number";
const String fieldAddress1 = "address1";
const String fieldAddress2 = "address2";
const String fieldAddress3 = "address3";
const String fieldAddress4 = "address4";
const String fieldPostcode = "postcode";
const String fieldCity = "city";
const String fieldState = "state";
const String fieldCountry = "country";
const String fieldTIN = "tin";
const String fieldSSTRegistrationNo = "sst_registration_no";
const String fieldTTXRegistrationNo = "ttx_registration_no";

// MemberProfile fields
const String fieldName = "name";
const String fieldEmail = "email";
const String fieldPassword = "password";
const String fieldImage = "image";
const String fieldBackgroundImage = "background_image";
const String fieldPersonalInvoiceImage = "personal_invoice_image";
const String fieldGender = "gender";
const String fieldDOB = "date_of_birth";
const String fieldAccountCode = "account_code";
const String fieldStatus = "status";
const String fieldToken = "token";

// WorkingProfile fields
const String fieldCompanyName = "company_name";
const String fieldCompanyEmail = "company_email";
const String fieldCompanyInvoiceImage = "company_invoice_image";
const String fieldROC = "roc";
const String fieldMSICCode = "msic_code";
const String fieldRegistrationSchemeID = "registration_scheme_id";
const String fieldRegistrationSchemeNo = "registration_scheme_no";

class ProfileModel {
  final int id;
  final String memberCode;
  final String countryCode;
  final String contactNumber;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final String postcode;
  final String city;
  final String state;
  final String country;
  final String tin;
  final String sstRegistrationNo;
  final String ttxRegistrationNo;

  ProfileModel({
    this.id = 0,
    this.memberCode = "",
    this.countryCode = "60",
    this.contactNumber = "",
    this.address1 = "",
    this.address2 = "",
    this.address3 = "",
    this.address4 = "",
    this.postcode = "",
    this.city = "",
    this.state = "",
    this.country = "",
    this.tin = "",
    this.sstRegistrationNo = "",
    this.ttxRegistrationNo = "",
  });

  factory ProfileModel.fromJson(Map<String, dynamic> data) => ProfileModel(
    id: data[fieldID] ?? 0,
    memberCode: data[fieldMemberCode] ?? "",
    countryCode: data[fieldCountryCode] ?? "60",
    contactNumber: data[fieldContactNumber] ?? "",
    address1: data[fieldAddress1] ?? "",
    address2: data[fieldAddress2] ?? "",
    address3: data[fieldAddress3] ?? "",
    address4: data[fieldAddress4] ?? "",
    postcode: data[fieldPostcode] ?? "",
    city: data[fieldCity] ?? "",
    state: data[fieldState] ?? "",
    country: data[fieldCountry] ?? "",
    tin: data[fieldTIN] ?? "",
    sstRegistrationNo: data[fieldSSTRegistrationNo] ?? "",
    ttxRegistrationNo: data[fieldTTXRegistrationNo] ?? "",
  );

  @override
  String toString() =>
      "\tid: $id, memberCode: $memberCode, countryCode: $countryCode, contactNumber: $contactNumber\n"
      "\taddress1: $address1, address2: $address2, address3: $address3, address4: $address4, postcode: $postcode, city: $city, state: $state, country: $country\n"
      "\ttin: $tin, sstRegistrationNo: $sstRegistrationNo, ttxRegistrationNo: $ttxRegistrationNo\n";
}

class MemberProfileModel extends ProfileModel {
  static const String keyMember = "personal_profile";

  final String name;
  final String email;
  final String password;
  final String image;
  final String backgroundImage;
  final String personalInvoiceImage;
  final String gender;
  final int dob;
  final String accountCode;
  final int status;
  final String token;

  MemberProfileModel({
    super.id,
    super.memberCode,
    super.countryCode,
    super.contactNumber,
    super.address1,
    super.address2,
    super.address3,
    super.address4,
    super.postcode,
    super.city,
    super.state,
    super.country,
    super.tin,
    super.sstRegistrationNo,
    super.ttxRegistrationNo,
    this.name = "",
    this.email = "",
    this.password = "",
    this.image = "",
    this.backgroundImage = "",
    this.personalInvoiceImage = "",
    this.gender = "",
    this.dob = 0,
    this.accountCode = "",
    this.status = 1,
    this.token = "",
  });

  MemberProfileModel.empty() : this();

  factory MemberProfileModel.fromJson(Map<String, dynamic> data) {
    final base = ProfileModel.fromJson(data);

    return MemberProfileModel(
      id: base.id,
      memberCode: base.memberCode,
      countryCode: base.countryCode,
      contactNumber: base.contactNumber,
      address1: base.address1,
      address2: base.address2,
      address3: base.address3,
      address4: base.address4,
      postcode: base.postcode,
      city: base.city,
      state: base.state,
      country: base.country,
      tin: base.tin,
      sstRegistrationNo: base.sstRegistrationNo,
      ttxRegistrationNo: base.ttxRegistrationNo,
      name: data[fieldName] ?? "",
      email: data[fieldEmail] ?? "",
      password: data[fieldPassword] ?? "",
      image: data[fieldImage] ?? "",
      backgroundImage: data[fieldBackgroundImage] ?? "",
      personalInvoiceImage: data[fieldPersonalInvoiceImage] ?? "",
      gender: data[fieldGender] ?? "",
      dob: data[fieldDOB] != null ? DateTime.tryParse(data[fieldDOB])?.millisecondsSinceEpoch ?? 0 : 0,
      accountCode: data[fieldAccountCode] ?? "",
      status: data[fieldStatus] ?? 1,
      token: data[fieldToken] ?? "",
    );
  }

  static Map<String, dynamic> toJsonUpdate({
    required String memberCode,
    required String countryCode,
    required String contactNumber,
    required String address1,
    required String address2,
    required String address3,
    required String address4,
    required String postcode,
    required String city,
    required String state,
    required String country,
    required String tin,
    required String sstRegistrationNo,
    required String ttxRegistrationNo,
    required String name,
    required String gender,
    required String dob,
    required String accountCode,
  }) => {
    fieldMemberCode: memberCode,
    fieldCountryCode: countryCode,
    fieldContactNumber: contactNumber,
    fieldAddress1: address1,
    fieldAddress2: address2,
    fieldAddress3: address3,
    fieldAddress4: address4,
    fieldPostcode: postcode,
    fieldCity: city,
    fieldState: state,
    fieldCountry: country,
    fieldTIN: tin,
    fieldSSTRegistrationNo: sstRegistrationNo,
    fieldTTXRegistrationNo: ttxRegistrationNo,
    fieldName: name,
    fieldGender: gender,
    fieldDOB: dob.isNotEmpty ? FormatterHelper.stringToDateTime(dob).toIso8601String() : null,
    fieldAccountCode: accountCode,
  };

  static Map<String, dynamic> toJsonSignUp(String name, String email, String countryCode, String contactNumber) => {
    fieldName: name,
    fieldEmail: email,
    fieldCountryCode: countryCode,
    fieldContactNumber: contactNumber,
  };

  static Map<String, dynamic> toJsonSignIn(String email, String countryCode, String contactNumber, String password) => {
    fieldEmail: email,
    fieldCountryCode: countryCode,
    fieldContactNumber: contactNumber,
    fieldPassword: password,
  };

  @override
  String toString() =>
      "MemberProfileModel(\n"
      "${super.toString()}"
      "\tname: $name, email: $email, password: $password, image: $image, backgroundImage: $backgroundImage, personalInvoiceImage: $personalInvoiceImage, gender: $gender, dob: $dob\n"
      "\taccountCode: $accountCode, status: $status, token: $token\n"
      ")";
}

class WorkingProfileModel extends ProfileModel {
  static const String keyWorking = "working_profile";

  final String companyName;
  final String companyEmail;
  final String companyInvoiceImage;
  final String roc;
  final String msicCode;
  final String registrationSchemeID;
  final String registrationSchemeNo;

  WorkingProfileModel({
    super.id,
    super.memberCode,
    super.countryCode,
    super.contactNumber,
    super.address1,
    super.address2,
    super.address3,
    super.address4,
    super.postcode,
    super.city,
    super.state,
    super.country,
    super.tin,
    super.sstRegistrationNo,
    super.ttxRegistrationNo,
    this.companyName = "",
    this.companyEmail = "",
    this.companyInvoiceImage = "",
    this.roc = "",
    this.msicCode = "",
    this.registrationSchemeID = "",
    this.registrationSchemeNo = "",
  });

  WorkingProfileModel.empty() : this();

  factory WorkingProfileModel.fromJson(Map<String, dynamic> data) {
    final base = ProfileModel.fromJson(data);

    return WorkingProfileModel(
      id: base.id,
      memberCode: base.memberCode,
      countryCode: base.countryCode,
      contactNumber: base.contactNumber,
      address1: base.address1,
      address2: base.address2,
      address3: base.address3,
      address4: base.address4,
      postcode: base.postcode,
      city: base.city,
      state: base.state,
      country: base.country,
      tin: base.tin,
      sstRegistrationNo: base.sstRegistrationNo,
      ttxRegistrationNo: base.ttxRegistrationNo,
      companyName: data[fieldCompanyName] ?? "",
      companyEmail: data[fieldCompanyEmail] ?? "",
      companyInvoiceImage: data[fieldCompanyInvoiceImage] ?? "",
      roc: data[fieldROC] ?? "",
      msicCode: data[fieldMSICCode] ?? "",
      registrationSchemeID: data[fieldRegistrationSchemeID] ?? "",
      registrationSchemeNo: data[fieldRegistrationSchemeNo] ?? "",
    );
  }

  static Map<String, dynamic> toJsonUpdate({
    required String memberCode,
    required String countryCode,
    required String contactNumber,
    required String address1,
    required String address2,
    required String address3,
    required String address4,
    required String postcode,
    required String city,
    required String state,
    required String country,
    required String tin,
    required String sstRegistrationNo,
    required String ttxRegistrationNo,
    required String name,
    required String email,
    required String roc,
    required String msic,
    required String registrationSchemeID,
    required String registrationSchemeNo,
  }) => {
    fieldMemberCode: memberCode,
    fieldCountryCode: countryCode,
    fieldContactNumber: contactNumber,
    fieldAddress1: address1,
    fieldAddress2: address2,
    fieldAddress3: address3,
    fieldAddress4: address4,
    fieldPostcode: postcode,
    fieldCity: city,
    fieldState: state,
    fieldCountry: country,
    fieldTIN: tin,
    fieldSSTRegistrationNo: sstRegistrationNo,
    fieldTTXRegistrationNo: ttxRegistrationNo,
    fieldCompanyName: name,
    fieldCompanyEmail: email,
    fieldROC: roc,
    fieldMSICCode: msic,
    fieldRegistrationSchemeID: registrationSchemeID,
    fieldRegistrationSchemeNo: registrationSchemeNo,
  };

  @override
  String toString() =>
      "WorkingProfileModel(\n"
      "${super.toString()}"
      "\tcompanyName: $companyName, companyEmail: $companyEmail, companyInvoiceImage: $companyInvoiceImage, roc: $roc, msicCode: $msicCode\n"
      "\tregistrationSchemeID: $registrationSchemeID, registrationSchemeNo: $registrationSchemeNo\n"
      ")";
}
