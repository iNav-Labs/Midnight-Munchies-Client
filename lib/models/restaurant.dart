class Restaurant {
  final String? id;
  final String? name;
  final String? address;
  final String? imageUrl;
  final bool isVeg;
  final bool isNonVeg;
  final double? rating;
  final bool isTrusted;

  Restaurant({
    this.id,
    this.name,
    this.address,
    this.imageUrl,
    required this.isVeg,
    required this.isNonVeg,
    this.rating,
    this.isTrusted = false,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isVeg: json['isVeg'] as bool? ?? false,
      isNonVeg: json['isNonVeg'] as bool? ?? false,
      rating: json['rating'] as double?,
      isTrusted: json['isTrusted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'isVeg': isVeg,
      'isNonVeg': isNonVeg,
      'rating': rating,
      'isTrusted': isTrusted,
    };
  }
} 