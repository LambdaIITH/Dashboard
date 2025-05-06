class MerchItem {
  final int id;
  final String title;
  final DateTime deadline;
  final double price;
  final String imageUrl;
  final List<MerchImage> images;
  final String description;
  final String upiId;
  final DateTime createdAt;
  final bool isOversized;
  final String sizeGuideUrl;
  final List<MerchSize> availableSizes;
  final bool hasSizes;

  MerchItem({
    required this.id,
    required this.title,
    required this.deadline,
    required this.price,
    required this.imageUrl,
    required this.images,
    required this.description,
    required this.upiId,
    required this.createdAt,
    required this.isOversized,
    required this.sizeGuideUrl,
    required this.availableSizes,
    required this.hasSizes,
  });

  factory MerchItem.fromJson(Map<String, dynamic> json) {
    List<MerchImage> imagesList = [];
    if (json['images'] != null) {
      imagesList = List<MerchImage>.from(
        (json['images'] as List).map((img) => MerchImage.fromJson(img)),
      );
    }

    List<MerchSize> sizesList = [];
    if (json['available_sizes'] != null) {
      sizesList = List<MerchSize>.from(
        (json['available_sizes'] as List).map((size) => MerchSize.fromJson(size)),
      );
    }

    double priceValue;
    if (json['price'] is String) {
      priceValue = double.tryParse(json['price']) ?? 0.0;
    } else {
      priceValue = (json['price'] as num).toDouble();
    }

    return MerchItem(
      id: json['id'],
      title: json['title'],
      deadline: DateTime.parse(json['deadline']),
      price: priceValue,
      imageUrl: json['image_url'],
      images: imagesList,
      description: json['description'] ?? '',
      upiId: json['upi_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      isOversized: json['is_oversized'] ?? false,
      sizeGuideUrl: json['size_guide_url'] ?? '',
      availableSizes: sizesList,
      hasSizes: json['has_sizes'] ?? (sizesList.isNotEmpty),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline.toIso8601String(),
      'price': price,
      'image_url': imageUrl,
      'images': images.map((img) => img.toJson()).toList(),
      'description': description,
      'upi_id': upiId,
      'created_at': createdAt.toIso8601String(),
      'is_oversized': isOversized,
      'size_guide_url': sizeGuideUrl,
      'available_sizes': availableSizes.map((size) => size.toJson()).toList(),
      'has_sizes': hasSizes,
    };
  }
}

class MerchImage {
  final String url;

  MerchImage({required this.url});

  factory MerchImage.fromJson(Map<String, dynamic> json) {
    return MerchImage(url: json['url']);
  }

  Map<String, dynamic> toJson() {
    return {'url': url};
  }
}

class MerchSize {
  final int id;
  final String name;

  MerchSize({required this.id, required this.name});

  factory MerchSize.fromJson(Map<String, dynamic> json) {
    return MerchSize(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}