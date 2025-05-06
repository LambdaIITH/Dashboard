class MerchOrder {
  final int id;
  final int merchId;
  final String title;
  final double price;
  final String imageUrl;
  final String? size;
  final bool status;
  final bool isOversized;
  final DateTime orderDate;
  final String transactionId;
  final String displayName;

  MerchOrder({
    required this.id,
    required this.merchId,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.size,
    required this.status,
    required this.isOversized,
    required this.orderDate,
    required this.transactionId,
    required this.displayName,
  });

  factory MerchOrder.fromJson(Map<String, dynamic> json) {
    String? size;
    if (json['size'] != null) {
      size = json['size'];
    }

    return MerchOrder(
      id: json['id'],
      merchId: json['merch_id'],
      title: json['title'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      size: size,
      status: json['status'],
      isOversized: json['is_oversized'] ?? false,
      orderDate: DateTime.parse(json['order_date']),
      transactionId: json['transaction_id'],
      displayName: json['display_name'],
    );
  }
}