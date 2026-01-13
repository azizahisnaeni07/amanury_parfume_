class UserData {
  static String? email;
  static String? password;

  static bool get isRegistered => email != null && password != null;
}
