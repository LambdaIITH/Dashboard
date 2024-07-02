class UserModel {
  int id;
  bool cr;
  String email;

  UserModel({required this.email, this.cr = false, this.id = -1,});
}