class AppStrings {
  // App Name
  static const String appName = "EzyMember";

  // App Server Url
  static const String serverUrl = "http://127.0.0.1:8000";
  static const String serverDirectory = "api";

  // Assets (Temporary variables only)
  static const String tmpIconHistory = "assets/images/tmp_ic_history.png";
  static const String tmpIconInvoice = "assets/images/tmp_ic_invoice.png";
  static const String tmpIconMyCredits = "assets/images/tmp_ic_my_credits.png";
  static const String tmpIconMyMember = "assets/images/tmp_ic_my_member.png";
  static const String tmpIconMyPoints = "assets/images/tmp_ic_my_points.png";
  static const String tmpIconMyVoucher = "assets/images/tmp_ic_my_voucher.png";
  static const String tmpIconReferralProgram = "assets/images/tmp_ic_referral_program.png";
  static const String tmpImgAppLogo = "assets/images/tmp_app_logo.png";
  static const String tmpImgBackground = "assets/images/tmp_background.jpg";
  static const String tmpImgDefaultAvatar = "assets/images/tmp_default_avatar.jpg";
  static const String tmpImgSignIn = "assets/images/tmp_sign_in.png";
  static const String tmpImgSignUp = "assets/images/tmp_sign_up.png";
  static const String tmpImgSplashLogo = "assets/images/tmp_splash_logo.jpg";
  static const String tmpImgWelcome = "assets/images/tmp_welcome.png";

  static const String jsonCountryCode = "assets/json/country_codes.json";
  static const String jsonPostcode = "assets/json/postcodes.json";

  List<String> genders = ["Male", "Female", "Prefer not to say"];
  List<String> idTypes = ["BRN", "NRIC", "PASSPORT", "ARMY"];

  Map<String, String> gender = {
    "M": "Male",
    "F": "Female",
    "O": "Prefer not to say",
  };

  Map<String, String> idType = {
    "brn": "BRN",
    "nric": "NRIC",
    "passport": "PASSPORT",
    "army": "ARMY",
  };
}
