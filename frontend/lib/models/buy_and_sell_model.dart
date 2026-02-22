class BuyAndSellModel {
  final String itemName;
  final String? description;
  final double price;
  final List<String> images;
  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? userPhoneNumber;
  final String? createdAt;

  const BuyAndSellModel({
    required this.id,
    required this.itemName,
    required this.price,
    required this.images,
    this.description,
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhoneNumber,
    this.createdAt,
  });

  factory BuyAndSellModel.fromJson(Map<String, dynamic> json) {
    return BuyAndSellModel(
      id: json['id'].toString(),
      itemName: json['name'] ?? json['item_name'] ?? '',
      description: json['description'],
      price: (json['selling_price'] ?? 0).toDouble(),
      images: json['images'] is List
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : <String>[],
      userId: json['user_id']?.toString(),
      userName: json['username'],
      userEmail: json['user_email'],
      userPhoneNumber: json['user_phone_number'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': itemName,
      'description': description,
      'price': price,
      'images': images,
      'user_id': userId,
      'username': userName,
      'user_email': userEmail,
      'user_phone_number': userPhoneNumber,
      'created_at': createdAt,
    };
  }
}
