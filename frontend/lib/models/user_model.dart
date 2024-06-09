class UserModel {
  int id;
  bool cr;
  String email;
  String? refreshToken;

  UserModel({required this.email, this.cr = false, this.id = -1, this.refreshToken});
}