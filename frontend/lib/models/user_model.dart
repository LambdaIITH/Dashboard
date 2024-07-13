class UserModel {
  int id;
  bool cr;
  String email;
  String name;
  String? phone;

  UserModel(
      {required this.email,
      this.cr = false,
      this.id = -1,
      required this.name,
      this.phone});
}
