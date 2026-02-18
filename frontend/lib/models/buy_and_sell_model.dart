import 'package:dashbaord/constants/enums/buy_and_sell.dart';

class BuyAndSellModel {
  final BuyOrSell buyOrSell;
  final String itemName;
  final String? itemDescription;
  final double price;
  final String? condition;
  final String? category;
  final List<String> images;
  final String id;
  final String? userName;
  final String? userEmail;

  const BuyAndSellModel({
    required this.id,
    required this.buyOrSell,
    required this.itemName,
    required this.price,
    this.itemDescription,
    this.condition,
    this.category,
    required this.images,
    this.userEmail,
    this.userName,
  });

  factory BuyAndSellModel.fromJson(Map<String, dynamic> json) {
    return BuyAndSellModel(
      userName: json['username'] ?? json['user_name'],
      userEmail: json['user_email'],
      id: json['id'].toString(),
      buyOrSell: BuyOrSell.sell, // Backend only has selling items for now
      itemName: json['name'] ?? json['item_name'] ?? '',
      price: (json['selling_price'] ?? json['price'] ?? 0).toDouble(),
      itemDescription: json['item_description'] ?? '',
      condition: json['condition'],
      category: json['category'],
      images: (json['images'] ?? json['image_urls'] ?? []) is List
          ? ((json['images'] ?? json['image_urls'] ?? []) as List).map((e) => e.toString()).toList()
          : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyOrSell': buyOrSell == BuyOrSell.buy ? 'buy' : 'sell',
      'name': itemName,
      'price': price,
      'item_description': itemDescription,
      'condition': condition,
      'category': category,
      'images': images,
      'user_email': userEmail,
      'username': userName,
    };
  }
}
