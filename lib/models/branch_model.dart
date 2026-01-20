const String fieldID = "id";
const String fieldCustomerID = "customer_id";
const String fieldBranchCode = "branch_code";
const String fieldBranchName = "branch_name";
const String fieldBranchDescription = "branch_description";
const String fieldContactNumber = "contact_number";
const String fieldContactNumber2 = "contact_number2";
const String fieldCompanyKey = "company_key";
const String fieldAddress1 = "address1";
const String fieldAddress2 = "address2";
const String fieldAddress3 = "address3";
const String fieldAddress4 = "address4";
const String fieldPostcode = "postcode";
const String fieldCity = "city";
const String fieldState = "state";
const String fieldLatitude = "latitude";
const String fieldLongitude = "longitude";

class BranchModel {
  static const String keyBranch = "branches";

  final int id;
  final String customerID;
  final String branchCode;
  final String branchName;
  final String branchDescription;
  final String contactNumber;
  final String contactNumber2;
  final String companyKey;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final String postcode;
  final String city;
  final String state;
  final double? latitude;
  final double? longitude;

  BranchModel({
    this.id = 0,
    this.customerID = "",
    this.branchCode = "",
    this.branchName = "",
    this.branchDescription = "",
    this.contactNumber = "",
    this.contactNumber2 = "",
    this.companyKey = "",
    this.address1 = "",
    this.address2 = "",
    this.address3 = "",
    this.address4 = "",
    this.postcode = "",
    this.city = "",
    this.state = "",
    this.latitude,
    this.longitude,
  });

  BranchModel.empty() : this();

  factory BranchModel.fromJson(Map<String, dynamic> data) => BranchModel(
    id: data[fieldID] ?? 0,
    customerID: data[fieldCustomerID] ?? "",
    branchCode: data[fieldBranchCode] ?? "",
    branchName: data[fieldBranchName] ?? "",
    branchDescription: data[fieldBranchDescription] ?? "",
    contactNumber: data[fieldContactNumber] ?? "",
    contactNumber2: data[fieldContactNumber2] ?? "",
    companyKey: data[fieldCompanyKey] ?? "",
    address1: data[fieldAddress1] ?? "",
    address2: data[fieldAddress2] ?? "",
    address3: data[fieldAddress3] ?? "",
    address4: data[fieldAddress4] ?? "",
    postcode: data[fieldPostcode] ?? "",
    city: data[fieldCity] ?? "",
    state: data[fieldState] ?? "",
    latitude: data[fieldLatitude] != null ? double.tryParse(data[fieldLatitude].toString()) : null,
    longitude: data[fieldLongitude] != null ? double.tryParse(data[fieldLongitude].toString()) : null,
  );

  String get fullAddress => [address1, address2, address3, address4, postcode, city, state].where((e) => e.isNotEmpty).join(", ");

  String toCompare() => "$branchName $fullAddress";

  @override
  String toString() =>
      "BranchModel(id: $id, customerID: $customerID, branchCode: $branchCode, branchName: $branchName, branchDescription: $branchDescription, contactNumber: $contactNumber, contactNumber2: $contactNumber2, companyKey: $companyKey, address1: $address1, address2: $address2, address3: $address3, address4: $address4, postcode: $postcode, city: $city, state: $state, latitude: $latitude, longitude: $longitude)\n";
}
