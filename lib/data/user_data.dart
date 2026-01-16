class UserData {
  static String? nama;
  static String? email;
  static String? alamat;
  static String? password;
  static String? phone;
  static String? profileImagePath;


  static bool get isRegistered =>
      email != null && password != null;
}
