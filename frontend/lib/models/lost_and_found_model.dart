import 'package:dashbaord/constants/enums/lost_and_found.dart';

class LostAndFoundModel {
  final LostOrFound lostOrFound;
  final String itemName;
  final String? itemDescription;
  final List<String> images;
  final String id;
  final String? userName;
  final String? userEmail;

  const LostAndFoundModel({
    required this.id,
    required this.lostOrFound,
    required this.itemName,
    this.itemDescription,
    required this.images,
    this.userEmail,
    this.userName,
  });

  // not done!!
  factory LostAndFoundModel.fromJson(Map<String, dynamic> json) {
    // debugPrint(json['images'][0]);
    return LostAndFoundModel(
      userName: json['username'],
      userEmail: json['user_email'],
      id: json['id'].toString(),
      lostOrFound: json['lostOrFound'],
      itemName: json['name'],
      itemDescription: json['item_description'],
      images: (json['images'] as List).isNotEmpty
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : <String>[],
    );
  }
}
