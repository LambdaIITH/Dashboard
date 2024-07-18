class TravellersModel {
  final String name;
  final String email;
  final String phoneNumber;
  final String comments;

  TravellersModel(
      {required this.name,
      required this.email,
      required this.phoneNumber,
      required this.comments});
  
  factory TravellersModel.fromJson(Map<String, dynamic> json) {
    return TravellersModel(
        name: json['name'],
        email: json['email'],
        phoneNumber: json['phone_number'],
        comments: json['comments']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'comments': comments
    };
  }
}
