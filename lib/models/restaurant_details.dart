class Restaurant {
  final String id;
  final String name;
  final String location;
  final bool isVeg;
  final bool isNonVeg;
  final String imageUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.isVeg,
    required this.isNonVeg,
    required this.imageUrl,
  });
}