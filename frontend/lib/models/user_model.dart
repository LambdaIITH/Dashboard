class UserModel {
  int id;
  bool cr;
  String email;
  String name;
  String? phone;

  // a function to get Roll Number from email
  // E.g., ma22btech11003@iith.ac.in -> MA22BTECH11003
  String getRollNumber() {
    List<String> parts = email.split('@');
    String rollno = parts[0];
    return rollno.toUpperCase();
  }

  UserModel(
      {required this.email,
      this.cr = false,
      this.id = -1,
      required this.name,
      this.phone});
}
