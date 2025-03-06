class CartItem {
  final String restaurantId;
  final String itemName;
  int quantity;

  CartItem({
    required this.restaurantId,
    required this.itemName,
    this.quantity = 1,
  });
}