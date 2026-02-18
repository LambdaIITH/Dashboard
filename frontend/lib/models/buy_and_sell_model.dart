class BuyAndSellModel {
  final String itemName;
  final double price;
  final List<String> images;
  final String id;
  final String? userId;

  const BuyAndSellModel({
    required this.id,
    required this.itemName,
    required this.price,
    required this.images,
    this.userId,
  });

  factory BuyAndSellModel.fromJson(Map<String, dynamic> json) {
    return BuyAndSellModel(
      id: json['id'].toString(),
      itemName: json['name'] ?? '',
      price: (json['selling_price'] ?? 0).toDouble(),
      images: json['images'] is List
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : <String>[],
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': itemName,
      'price': price,
      'images': images,
      'user_id': userId,
    };
  }
}
